import CoreGraphics
import Combine

class AnnotationPaletteViewModel: ObservableObject {
    weak var parentViewModel: AnnotationViewModel?

    private(set) var origin: CGPoint
    private(set) var width: Double
    private(set) var height: Double

    private(set) var isEditing = false
    @Published private(set) var textIsSelected = false
    @Published private(set) var markdownIsSelected = false

    init(origin: CGPoint, width: Double, height: Double) {
        self.origin = origin
        self.width = width
        self.height = height
    }

    func didSelectTextButton() {
        textIsSelected = true
        markdownIsSelected = false
        parentViewModel?.appendTextPartIfNecessary()
    }

    func didSelectMarkdownButton() {
        textIsSelected = false
        markdownIsSelected = true
        parentViewModel?.appendMarkdownPartIfNecessary()
    }

    func enterEditMode() {
        isEditing = true
        parentViewModel?.enterEditMode()
    }

    func enterViewMode() {
        isEditing = false
        parentViewModel?.enterViewMode()
    }
}

// MARK: Position, Size
extension AnnotationPaletteViewModel {
    var size: CGSize {
        CGSize(width: width, height: height)
    }

    var frame: CGRect {
        CGRect(origin: origin, size: size)
    }
}
