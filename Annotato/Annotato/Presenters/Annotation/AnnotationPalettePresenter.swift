import CoreGraphics
import Combine

class AnnotationPalettePresenter: ObservableObject {
    weak var parentPresenter: AnnotationPresenter? {
        didSet {
            setUpSubscribers()
        }
    }
    private var cancellables: Set<AnyCancellable> = []

    private(set) var origin: CGPoint
    private(set) var width: Double
    private(set) var height: Double

    @Published var isMinimized = true

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
                handwritingIsSelected = false
            }
        }
    }
    @Published private(set) var markdownIsSelected = false {
        didSet {
            if markdownIsSelected {
                textIsSelected = false
                handwritingIsSelected = false
            }
        }
    }
    @Published private(set) var handwritingIsSelected = false {
        didSet {
            if handwritingIsSelected {
                textIsSelected = false
                markdownIsSelected = false
            }
        }
    }

    init(origin: CGPoint, width: Double, height: Double) {
        self.origin = origin
        self.width = width
        self.height = height
    }

    private func setUpSubscribers() {
        parentPresenter?.$isMinimized.sink(receiveValue: { [weak self] isMinimized in
            self?.isMinimized = isMinimized
        }).store(in: &cancellables)
    }

    func didSelectTextButton() {
        guard parentPresenter?.isEditing ?? false else {
            return
        }
        textIsSelected = true
        parentPresenter?.appendTextPartIfNecessary()
    }

    func didSelectMarkdownButton() {
        guard parentPresenter?.isEditing ?? false else {
            return
        }
        markdownIsSelected = true
        parentPresenter?.appendMarkdownPartIfNecessary()
    }

    func didSelectHandwritingButton() {
        guard parentPresenter?.isEditing ?? false else {
            return
        }
        handwritingIsSelected = true
        parentPresenter?.appendHandwritingPartIfNecessary()
    }

    func enterEditMode() {
        isEditing = true
        parentPresenter?.enterEditMode()
    }

    func enterViewMode() {
        isEditing = false
        parentPresenter?.enterViewMode()
    }

    func didSelectDeleteButton() {
        parentPresenter?.didDelete()
    }

    func didSelectMinimizeOrMaximizeButton() {
        let isNowMinimized = !isMinimized
        if isNowMinimized {
            enterMinimizedMode()
        } else {
            enterMaximizedMode()
        }
    }

    func enterMinimizedMode() {
        parentPresenter?.enterMinimizedMode()
    }

    func enterMaximizedMode() {
        parentPresenter?.enterMaximizedMode()
    }

    func updatePalette(basedOn selectedPart: AnnotationPartPresenter) {
        switch selectedPart {
        case is AnnotationTextPresenter:
            textIsSelected = true
        case is AnnotationMarkdownPresenter:
            markdownIsSelected = true
        case is AnnotationHandwritingPresenter:
            handwritingIsSelected = true
        default:
            return
        }
    }
}

extension AnnotationPalettePresenter {
    var size: CGSize {
        CGSize(width: width, height: height)
    }

    var frame: CGRect {
        CGRect(origin: origin, size: size)
    }

    func translateUp(by yTranslation: CGFloat) {
        origin = CGPoint(x: origin.x, y: origin.y - yTranslation)
    }
}
