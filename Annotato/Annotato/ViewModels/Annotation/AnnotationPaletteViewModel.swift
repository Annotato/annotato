import CoreGraphics
import Combine

class AnnotationPaletteViewModel: ObservableObject {
    weak var parentViewModel: AnnotationViewModel?

    private(set) var origin: CGPoint
    private(set) var width: Double
    private(set) var height: Double

    var isMinimized: Bool {
        parentViewModel?.isMinimized ?? false
    }

    @Published var isEditing = false {
        didSet {
            if !isEditing {
                textIsSelected = false
                markdownIsSelected = false
            }
        }
    }
    @Published private(set) var textIsSelected = false {
        didSet {
            if textIsSelected {
                markdownIsSelected = false
            }
        }
    }
    @Published private(set) var markdownIsSelected = false {
        didSet {
            if markdownIsSelected {
                textIsSelected = false
            }
        }
    }

    init(origin: CGPoint, width: Double, height: Double) {
        self.origin = origin
        self.width = width
        self.height = height
    }

    func didSelectTextButton() {
        guard parentViewModel?.isEditing ?? false else {
            return
        }
        textIsSelected = true
        parentViewModel?.appendTextPartIfNecessary()
    }

    func didSelectMarkdownButton() {
        guard parentViewModel?.isEditing ?? false else {
            return
        }
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

    func didSelectDeleteButton() {
        parentViewModel?.didDelete()
    }

    func enterMinimizedMode() {
        parentViewModel?.enterMinimizedMode()
    }

    func enterMaximizedMode() {
        parentViewModel?.enterMaximizedMode()
    }

    func updatePalette(basedOn selectedPart: AnnotationPartViewModel) {
        if selectedPart is AnnotationTextViewModel {
            textIsSelected = true
        }

        if selectedPart is AnnotationMarkdownViewModel {
            markdownIsSelected = true
        }
    }
}

extension AnnotationPaletteViewModel {
    var size: CGSize {
        CGSize(width: width, height: height)
    }

    var frame: CGRect {
        CGRect(origin: origin, size: size)
    }
}
