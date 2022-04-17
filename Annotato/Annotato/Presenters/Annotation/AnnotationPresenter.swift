import CoreGraphics
import Foundation
import CoreImage
import PDFKit
import AnnotatoSharedLibrary
import Combine

class AnnotationPresenter: ObservableObject {
    private let annotationsInteractor: AnnotationsInteractor?
    private let webSocketManager: WebSocketManager?

    private weak var document: DocumentPresenter?

    private(set) var model: Annotation
    private var cancellables: Set<AnyCancellable> = []

    private(set) var parts: [AnnotationPartPresenter]
    private(set) var palette: AnnotationPalettePresenter
    private(set) var mergeConflictPalette: AnnotationMergeConflictsPalettePresenter?
    private(set) var selectionBox: SelectionBoxPresenter
    private(set) var isEditing = false
    private(set) var selectedPart: AnnotationPartPresenter?
    private var maxHeight = 300.0
    private(set) var isInFocus = false

    var id: UUID {
        model.id
    }

    var origin: CGPoint {
        model.origin
    }

    @Published private(set) var positionDidChange = false
    @Published private(set) var isResizing = false
    @Published private(set) var addedPart: AnnotationPartPresenter?
    @Published private(set) var isRemoved = false
    @Published private(set) var isMinimized = true
    @Published private(set) var modelWasUpdated = false

    @Published private(set) var conflictIdx: Int? {
        willSet {
            model.conflictIdx = newValue
        }
    }
    private(set) var resolveBySave = false
    var isResolving: Bool {
        conflictIdx != nil
    }

    init(
        model: Annotation,
        document: DocumentPresenter,
        webSocketManager: WebSocketManager?,
        palette: AnnotationPalettePresenter? = nil
    ) {
        self.model = model
        self.document = document

        if let conflictIdx = model.conflictIdx {
            self.conflictIdx = conflictIdx
            self.mergeConflictPalette = AnnotationMergeConflictsPalettePresenter(
                origin: .zero, width: model.width, height: 50.0, conflictIdx: conflictIdx)
        }

        self.palette = palette ?? AnnotationPalettePresenter(
            origin: CGPoint(x: 0.0, y: mergeConflictPalette?.height ?? 0.0), width: model.width, height: 50.0)

        self.parts = []
        self.selectionBox = SelectionBoxPresenter(model: model.selectionBox)
        self.webSocketManager = webSocketManager
        self.annotationsInteractor = AnnotationsInteractor(webSocketManager: webSocketManager)
        self.palette.parentPresenter = self
        self.mergeConflictPalette?.parentPresenter = self

        populatePartPresenters(model: model)
        setUpSubscribers()
    }

    private func populatePartPresenters(model: Annotation) {
        for part in model.parts where !part.isDeleted {
            let partPresenter: AnnotationPartPresenter

            switch part {
            case let textPart as AnnotationText:
                switch textPart.type {
                case .plainText:
                    partPresenter = AnnotationTextPresenter(model: textPart, width: model.width)
                case .markdown:
                    partPresenter = AnnotationMarkdownPresenter(model: textPart, width: model.width)
                }
            case let handwritingPart as AnnotationHandwriting:
                partPresenter = AnnotationHandwritingPresenter(model: handwritingPart, width: model.width)
            default:
                continue
            }

            partPresenter.parentPresenter = self
            parts.append(partPresenter)
        }
    }

    func translateCenter(by translation: CGPoint) {
        center = CGPoint(x: center.x + translation.x, y: center.y + translation.y)

        guard !isResolving else {
            return
        }

        Task {
            await annotationsInteractor?.updateAnnotation(annotation: model)
        }
    }

    private func setUpSubscribers() {
        model.$addedTextPart.sink(receiveValue: { [weak self] addedTextPart in
            guard let addedTextPart = addedTextPart else {
                return
            }
            self?.addTextPart(part: addedTextPart)
        }).store(in: &cancellables)

        model.$addedMarkdownPart.sink(receiveValue: { [weak self] addedMarkdownPart in
            guard let addedMarkdownPart = addedMarkdownPart else {
                return
            }
            self?.addMarkdownPart(part: addedMarkdownPart)
        }).store(in: &cancellables)

        model.$addedHandwritingPart.sink(receiveValue: { [weak self] addedHandwritingPart in
            guard let addedHandwritingPart = addedHandwritingPart else {
                return
            }
            self?.addHandwritingPart(part: addedHandwritingPart)
        }).store(in: &cancellables)

        model.$origin.sink(receiveValue: { [weak self] _ in
            self?.positionDidChange = true
        }).store(in: &cancellables)

        model.$removedPart.sink(receiveValue: { [weak self] removedPart in
            self?.parts.removeAll(where: { $0.id == removedPart?.id })
            self?.resize()
        }).store(in: &cancellables)
    }
}

extension AnnotationPresenter {
    var center: CGPoint {
        get {
            CGPoint(x: origin.x + model.width / 2, y: origin.y + height / 2)
        }
        set(newCenter) {
            let newOrigin = CGPoint(x: newCenter.x - model.width / 2, y: newCenter.y - height / 2)
            model.setOrigin(to: newOrigin)
        }
    }

    var partsTotalHeight: Double {
        parts.reduce(0, { acc, part in
            acc + part.height
        })
    }

    var height: Double {
        min((mergeConflictPalette?.height ?? 0.0) + palette.height + partsTotalHeight, maxHeight)
    }

    var minimizedHeight: Double {
        min((mergeConflictPalette?.height ?? 0.0) + palette.height + 30.0, maxHeight)
    }

    var size: CGSize {
        CGSize(width: model.width, height: height)
    }

    var minimizedSize: CGSize {
        CGSize(width: model.width, height: minimizedHeight)
    }

    private var maximizedFrame: CGRect {
        CGRect(origin: model.origin, size: size)
    }

    private var minimizedFrame: CGRect {
        CGRect(origin: model.origin, size: minimizedSize)
    }

    var frame: CGRect {
        isMinimized ? minimizedFrame : maximizedFrame
    }

    // Note: scrollFrame is with respect to this frame
    var scrollFrame: CGRect {
        CGRect(
            x: .zero,
            y: mergeConflictPalette?.height ?? 0.0 + palette.height,
            width: model.width,
            height: partsTotalHeight
        )
    }

    // Note: partsFrame is with respect to scrollFrame
    var partsFrame: CGRect {
        CGRect(x: .zero, y: .zero, width: model.width, height: partsTotalHeight)
    }

    func hasExceededBounds(bounds: CGRect) -> Bool {
        !bounds.contains(frame)
    }
}

// MARK: Parts
extension AnnotationPresenter {
    func enterEditMode() {
        inFocus()
        isEditing = true
        palette.isEditing = true
        for part in parts {
            part.enterEditMode()
        }

        guard let lastPart = parts.last else {
            return
        }
        setSelectedPart(to: lastPart)
    }

    func enterViewMode() {
        guard isEditing else {
            return
        }

        isEditing = false
        palette.isEditing = false
        deselectSelectedPart()
        for part in parts {
            part.enterViewMode()
        }

        guard !isResolving else {
            return
        }

        Task {
            await annotationsInteractor?.updateAnnotation(annotation: model)
        }
    }

    func resize() {
        isResizing = true
    }

    func setSelectedPart(to selectedPart: AnnotationPartPresenter) {
        deselectSelectedPart()
        self.selectedPart = selectedPart
        self.selectedPart?.isSelected = true
        palette.updatePalette(basedOn: selectedPart)
    }

    func deselectSelectedPart() {
        guard let selectedPart = selectedPart else {
            return
        }
        selectedPart.isSelected = false
        removePartIfPossible(part: selectedPart)
        self.selectedPart = nil
    }

    func appendTextPartIfNecessary() {
        model.appendTextPartIfNecessary()
    }

    func appendMarkdownPartIfNecessary() {
        model.appendMarkdownPartIfNecessary()
    }

    func appendHandwritingPartIfNecessary() {
        model.appendHandwritingPartIfNecessary()
    }

    private func addTextPart(part: AnnotationText) {
        let partPresenter = AnnotationTextPresenter(model: part, width: model.width)
        addNewPart(newPart: partPresenter)
    }

    private func addMarkdownPart(part: AnnotationText) {
        let partPresenter = AnnotationMarkdownPresenter(model: part, width: model.width)
        addNewPart(newPart: partPresenter)
    }

    private func addHandwritingPart(part: AnnotationHandwriting) {
        let partPresenter = AnnotationHandwritingPresenter(model: part, width: model.width)
        addNewPart(newPart: partPresenter)
    }

    private func addNewPart(newPart: AnnotationPartPresenter) {
        newPart.parentPresenter = self
        newPart.enterEditMode()
        parts.append(newPart)
        addedPart = newPart
        setSelectedPart(to: newPart)
        resize()
    }

    private func removePartIfPossible(part: AnnotationPartPresenter) {
        model.removePartIfPossible(part: part.model)
    }

    func enterMinimizedMode() {
        isMinimized = true
        enterViewMode()
        resize()
    }

    func enterMaximizedMode() {
        inFocus()
        isMinimized = false
        resize()
    }
}

extension AnnotationPresenter {
    func didDelete() {
        guard !isResolving else {
            return
        }
        isRemoved = true
        selectionBox.didDelete()
        document?.deleteAnnotation(annotation: self)
    }

    func didSaveMergeConflicts() {
        guard NetworkMonitor.shared.isConnected else {
            AnnotatoLogger.error("Save merge conflict button pressed while offline")
            return
        }
        Task {
            _ = await annotationsInteractor?.createOrUpdateAnnotation(annotation: model)
        }
        resolveBySave = true
        self.conflictIdx = nil
        self.mergeConflictPalette = nil
    }

    func didDiscardMergeConflicts() {
        guard NetworkMonitor.shared.isConnected else {
            AnnotatoLogger.error("Discard merge conflict button pressed while offline")
            return
        }
        selectionBox.didDelete()
        document?.removeAnnotation(annotation: self)
        model.setDeletedAt(to: Date())
        Task {
            _ = await annotationsInteractor?.createOrUpdateAnnotation(annotation: model)
        }
        isRemoved = true
        self.conflictIdx = nil
        self.mergeConflictPalette = nil
    }

    func receiveDelete() {
        isRemoved = true
        selectionBox.receiveDelete()
    }

    func receiveUpdate(updatedAnnotation: Annotation) {
        let previousModel = self.model
        self.model = updatedAnnotation

        self.cancellables = []
        self.setUpSubscribers()

        self.positionDidChange = true

        if !updatedAnnotation.onlyPositionIsDifferent(from: previousModel) {
            self.parts = []
            self.populatePartPresenters(model: updatedAnnotation)
            self.modelWasUpdated = true
        }
    }

    func inFocus() {
        isInFocus = true
        document?.setAllOtherAnnotationsOutOfFocus(except: self)
    }

    func outOfFocus() {
        isInFocus = false
        enterViewMode()
    }
}
