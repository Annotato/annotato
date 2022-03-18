import CoreGraphics
import Foundation
import CoreImage
import PDFKit

class AnnotationViewModel: ObservableObject {
    private(set) var id: UUID
    private(set) var width: Double
    private(set) var parts: [AnnotationPartViewModel]
    private(set) var palette: AnnotationPaletteViewModel
    private(set) var isEditing = false
    private(set) var selectedPart: AnnotationPartViewModel?
    private var maxHeight = 300.0

    @Published private(set) var originInDocumentSpace: CGPoint
    @Published private(set) var isResizing = false
    @Published private(set) var partToAppend: AnnotationPartViewModel?
    @Published private(set) var isRemoved = false
    @Published private(set) var isMinimized = false

    unowned var associatedDocumentPdfViewModel: PdfViewModel?
    var associatedDocument: PDFDocument
    var associatedPage: PDFPage
    var coordinatesInPageSpace: CGPoint

    init(
        id: UUID,
        originInDocumentSpace: CGPoint,
        associatedDocumentPdfViewModel: PdfViewModel,
        associatedPage: PDFPage,
        coordinatesInPageSpace: CGPoint,
        width: Double,
        parts: [AnnotationPartViewModel],
        palette: AnnotationPaletteViewModel? = nil
    ) {
        self.id = id
        self.originInDocumentSpace = originInDocumentSpace

        self.associatedDocumentPdfViewModel = associatedDocumentPdfViewModel
        self.associatedDocument = associatedDocumentPdfViewModel.document
        self.associatedPage = associatedPage
        self.coordinatesInPageSpace = coordinatesInPageSpace

        self.width = width
        self.parts = parts
        self.palette = palette ?? AnnotationPaletteViewModel(origin: .zero, width: width, height: 50.0)

        self.palette.parentViewModel = self

        for part in self.parts {
            part.parentViewModel = self
        }
        if self.parts.isEmpty {
            addInitialPartIfNew()
        }
    }

    private func addInitialPartIfNew() {
        let newPart = makeNewTextPart()
        newPart.parentViewModel = self
        newPart.enterEditMode()
        parts.append(newPart)
        setSelectedPart(to: newPart)
        resize()
    }

    func updateLocation(documentViewPoint: CGPoint, parentView: UIView?) {
        guard let parentView = parentView else {
            return
        }
        guard let pdfView = parentView.superview?.superview
        as? DocumentPdfView else {
            return
        }

        // Get coordinates in terms of the visible view page space
        let visibleViewCoordinates = parentView.convert(
            documentViewPoint, to: parentView.superview?.superview)

        // Get the current page that this annotation is at
        guard let currPage = pdfView.page(
            for: visibleViewCoordinates, nearest: true) else {
            return
        }
        // Get the page space coordinates
        let pageSpaceCoordinates = pdfView.convert(visibleViewCoordinates, to: currPage)

        // Assign all the new values to update
        self.associatedPage = currPage
        self.coordinatesInPageSpace = pageSpaceCoordinates
        self.originInDocumentSpace = documentViewPoint
    }
}

extension AnnotationViewModel {
    var center: CGPoint {
        get {
            CGPoint(x: originInDocumentSpace.x + width / 2, y: originInDocumentSpace.y + height / 2)
        }
        set(newCenter) {
            originInDocumentSpace = CGPoint(x: newCenter.x - width / 2, y: newCenter.y - height / 2)
        }
    }

    var partHeights: Double {
        parts.reduce(0, {acc, part in
            acc + part.height
        })
    }

    var firstPartHeight: Double {
        parts.isEmpty ? 0 : parts[0].height
    }

    var height: Double {
        min(palette.height + partHeights, maxHeight)
    }

    var minimizedHeight: Double {
        min(palette.height + firstPartHeight, maxHeight)
    }

    var size: CGSize {
        CGSize(width: width, height: height)
    }

    var minimizedSize: CGSize {
        CGSize(width: width, height: minimizedHeight)
    }

    private var maximizedFrame: CGRect {
        CGRect(origin: originInDocumentSpace, size: size)
    }

    private var minimizedFrame: CGRect {
        CGRect(origin: originInDocumentSpace, size: minimizedSize)
    }

    var frame: CGRect {
        isMinimized ? minimizedFrame : maximizedFrame
    }

    // Note: scrollFrame is with respect to this frame
    var scrollFrame: CGRect {
        CGRect(x: .zero, y: palette.height, width: width, height: partHeights)
    }

    // Note: partsFrame is with respect to scrollFrame
    var partsFrame: CGRect {
        CGRect(x: .zero, y: .zero, width: width, height: partHeights)
    }
}

// MARK: Parts
extension AnnotationViewModel {
    func enterEditMode() {
        isEditing = true
        palette.isEditing = true
        for part in parts {
            part.enterEditMode()
        }
        selectedPart = parts.last
    }

    func enterViewMode() {
        isEditing = false
        palette.isEditing = false
        deselectSelectedPart()
        for part in parts {
            part.enterViewMode()
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
        removeIfPossible(part: selectedPart)
        self.selectedPart = nil
    }

    func appendTextPartIfNecessary() {
        guard let lastPart = parts.last else {
            return
        }

        removeIfPossible(part: lastPart)

        // The current last part is what we want, return
        if let currentLastPart = parts.last {
            if currentLastPart is AnnotationTextViewModel {
                setSelectedPart(to: currentLastPart)
                resize()
                return
            }
        }

        let newPart = makeNewTextPart()
        addNewPart(newPart: newPart)
    }

    func appendMarkdownPartIfNecessary() {
        guard let lastPart = parts.last else {
            return
        }

        removeIfPossible(part: lastPart)

        // The current last part is what we want, return
        if let currentLastPart = parts.last {
            if currentLastPart is AnnotationMarkdownViewModel {
                setSelectedPart(to: currentLastPart)
                resize()
                return
            }
        }

        let newPart = makeNewMarkdownPart()
        addNewPart(newPart: newPart)
    }

    private func makeNewTextPart() -> AnnotationTextViewModel {
        AnnotationTextViewModel(id: UUID(), content: "", width: width, height: 30.0)
    }

    private func makeNewMarkdownPart() -> AnnotationMarkdownViewModel {
        AnnotationMarkdownViewModel(id: UUID(), content: "", width: width, height: 30.0)
    }

    private func addNewPart(newPart: AnnotationPartViewModel) {
        newPart.parentViewModel = self
        newPart.enterEditMode()
        parts.append(newPart)
        partToAppend = newPart
        setSelectedPart(to: newPart)
        resize()
    }

    // Each presented annotation should have at least 1 part
    private func canRemovePart(part: AnnotationPartViewModel) -> Bool {
        part.isEmpty && parts.count > 1
    }

    func removeIfPossible(part: AnnotationPartViewModel) {
        guard canRemovePart(part: part) else {
            return
        }
        part.remove()
        parts.removeAll(where: { $0.id == part.id })
        resize()
    }

    func enterMinimizedMode() {
        isMinimized = true
        enterViewMode()
        resize()
    }

    func enterMaximizedMode() {
        isMinimized = false
        resize()
    }
}

extension AnnotationViewModel {
    func didDelete() {
        isRemoved = true
    }
}
