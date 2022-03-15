import CoreGraphics
import Foundation

class AnnotationViewModel: ObservableObject {
    private(set) var id: UUID
    private(set) var origin: CGPoint
    private(set) var width: Double
    private(set) var parts: [AnnotationPartViewModel]
    private(set) var palette: AnnotationPaletteViewModel

    private(set) var isEditing = false
    private(set) var selectedPart: AnnotationPartViewModel?
    @Published private(set) var isResizing = false
    @Published private(set) var partToAppend: AnnotationPartViewModel?
    @Published private(set) var isRemoved = false

    init(
        id: UUID,
        origin: CGPoint,
        width: Double,
        parts: [AnnotationPartViewModel],
        palette: AnnotationPaletteViewModel? = nil
    ) {
        self.id = id
        self.origin = origin
        self.width = width
        self.parts = parts
        self.palette = palette ?? AnnotationPaletteViewModel(origin: .zero, width: width, height: 50.0)
        self.palette.parentViewModel = self
        for part in self.parts {
            part.parentViewModel = self
        }
    }
}

// MARK: Position, Size
extension AnnotationViewModel {
    var partHeights: Double {
        parts.reduce(0, {acc, part in
            acc + part.height
        })
    }

    var height: Double {
        palette.height + partHeights
    }

    var size: CGSize {
        CGSize(width: width, height: height)
    }

    var frame: CGRect {
        CGRect(origin: origin, size: size)
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
        for part in parts {
            part.enterEditMode()
        }
        selectedPart = parts.last
    }

    func enterViewMode() {
        isEditing = false
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
    }

    func deselectSelectedPart() {
        guard let selectedPart = selectedPart else {
            return
        }
        selectedPart.isSelected = false
        if selectedPart.isEmpty {
            remove(part: selectedPart)
        }
        self.selectedPart = nil
    }

    func appendTextPartIfNecessary() {
        guard let lastPart = parts.last else {
            return
        }

        // If the last part is empty, remove it
        if lastPart.isEmpty {
            remove(part: lastPart)
        }

        // The last part is already what we want
        if let nextLastPart = parts.last {
            if nextLastPart is AnnotationTextViewModel {
                setSelectedPart(to: nextLastPart)
                resize()
                return
            }
        }

        let newPart = AnnotationTextViewModel(
            id: UUID(), content: "", width: width, height: 30.0)
        newPart.parentViewModel = self
        newPart.enterEditMode()
        parts.append(newPart)
        partToAppend = newPart
        setSelectedPart(to: newPart)
        resize()
    }

    func appendMarkdownPartIfNecessary() {
        guard let lastPart = parts.last else {
            return
        }

        // If the last part is empty, remove it
        if lastPart.isEmpty {
            remove(part: lastPart)
        }

        // The last part is already what we want
        if let nextLastPart = parts.last {
            if nextLastPart is AnnotationMarkdownViewModel {
                setSelectedPart(to: lastPart)
                resize()
                return
            }
        }

        let newPart = AnnotationMarkdownViewModel(
            id: UUID(), content: "", width: width, height: 30.0)
        newPart.parentViewModel = self
        newPart.enterEditMode()
        parts.append(newPart)
        partToAppend = newPart
        setSelectedPart(to: newPart)
        resize()
    }

    func remove(part: AnnotationPartViewModel) {
        part.remove()
        parts.removeAll(where: { $0.id == part.id })
        resize()
    }
}

extension AnnotationViewModel {
    func didDelete() {
        isRemoved = true
    }
}
