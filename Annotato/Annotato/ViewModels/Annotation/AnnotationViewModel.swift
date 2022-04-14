import CoreGraphics
import Foundation
import CoreImage
import PDFKit
import AnnotatoSharedLibrary
import Combine

class AnnotationViewModel: ObservableObject {
    private let annotationsPersistenceManager: AnnotationsPersistenceManager?
    private let webSocketManager: WebSocketManager?

    private weak var document: DocumentViewModel?

    private(set) var model: Annotation
    private var cancellables: Set<AnyCancellable> = []

    private(set) var parts: [AnnotationPartViewModel]
    private(set) var palette: AnnotationPaletteViewModel
    private(set) var mergeConflictPalette: AnnotationMergeConflictsPaletteViewModel?
    private(set) var selectionBox: SelectionBoxViewModel
    private(set) var isEditing = false
    private(set) var selectedPart: AnnotationPartViewModel?
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
    @Published private(set) var addedPart: AnnotationPartViewModel?
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
        document: DocumentViewModel,
        webSocketManager: WebSocketManager?,
        palette: AnnotationPaletteViewModel? = nil
    ) {
        self.model = model
        self.document = document

        let mergeConflictsPalette: AnnotationMergeConflictsPaletteViewModel?
        if let conflictIdx = model.conflictIdx {
            self.conflictIdx = conflictIdx
            mergeConflictsPalette = AnnotationMergeConflictsPaletteViewModel(
                origin: .zero, width: model.width, height: 50.0, conflictIdx: conflictIdx)
            self.mergeConflictPalette = mergeConflictsPalette
        } else {
            mergeConflictsPalette = nil
            self.mergeConflictPalette = mergeConflictsPalette
        }

        self.palette = palette ?? AnnotationPaletteViewModel(
            origin: CGPoint(x: 0.0, y: mergeConflictsPalette?.height ?? 0.0), width: model.width, height: 50.0)

        self.parts = []
        self.selectionBox = SelectionBoxViewModel(model: model.selectionBox)
        self.webSocketManager = webSocketManager
        self.annotationsPersistenceManager = AnnotationsPersistenceManager(webSocketManager: webSocketManager)
        self.palette.parentViewModel = self
        self.mergeConflictPalette?.parentViewModel = self

        populatePartViewModels(model: model)
        setUpSubscribers()
    }

    private func populatePartViewModels(model: Annotation) {
        for part in model.parts where !part.isDeleted {
            let partViewModel: AnnotationPartViewModel

            switch part {
            case let textPart as AnnotationText:
                switch textPart.type {
                case .plainText:
                    partViewModel = AnnotationTextViewModel(model: textPart, width: model.width)
                case .markdown:
                    partViewModel = AnnotationMarkdownViewModel(model: textPart, width: model.width)
                }
            case let handwritingPart as AnnotationHandwriting:
                partViewModel = AnnotationHandwritingViewModel(model: handwritingPart, width: model.width)
            default:
                continue
            }

            partViewModel.parentViewModel = self
            parts.append(partViewModel)
        }
    }

    func translateCenter(by translation: CGPoint) {
        center = CGPoint(x: center.x + translation.x, y: center.y + translation.y)

        if !isResolving {
            Task {
                await annotationsPersistenceManager?.updateAnnotation(annotation: model)
            }
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

extension AnnotationViewModel {
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
extension AnnotationViewModel {
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
        isEditing = false
        palette.isEditing = false
        deselectSelectedPart()
        for part in parts {
            part.enterViewMode()
        }

        if !isResolving {
            Task {
                await annotationsPersistenceManager?.updateAnnotation(annotation: model)
            }
        }
    }

    func resize() {
        isResizing = true
    }

    func setSelectedPart(to selectedPart: AnnotationPartViewModel) {
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
        let partViewModel = AnnotationTextViewModel(model: part, width: model.width)
        addNewPart(newPart: partViewModel)
    }

    private func addMarkdownPart(part: AnnotationText) {
        let partViewModel = AnnotationMarkdownViewModel(model: part, width: model.width)
        addNewPart(newPart: partViewModel)
    }

    private func addHandwritingPart(part: AnnotationHandwriting) {
        let partViewModel = AnnotationHandwritingViewModel(model: part, width: model.width)
        addNewPart(newPart: partViewModel)
    }

    private func addNewPart(newPart: AnnotationPartViewModel) {
        newPart.parentViewModel = self
        newPart.enterEditMode()
        parts.append(newPart)
        addedPart = newPart
        setSelectedPart(to: newPart)
        resize()
    }

    private func removePartIfPossible(part: AnnotationPartViewModel) {
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

extension AnnotationViewModel {
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
            await annotationsPersistenceManager?.createOrUpdateAnnotation(annotation: model)
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
            await annotationsPersistenceManager?.createOrUpdateAnnotation(annotation: model)
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
        self.model = updatedAnnotation

        self.cancellables = []
        self.setUpSubscribers()

        self.positionDidChange = true

        self.parts = []
        self.populatePartViewModels(model: updatedAnnotation)
        self.modelWasUpdated = true
    }

    func inFocus() {
        isInFocus = true
        document?.setAllOtherAnnotationsOutOfFocus(except: self)
    }

    func outOfFocus() {
        isInFocus = false
        enterMinimizedMode()
    }
}
