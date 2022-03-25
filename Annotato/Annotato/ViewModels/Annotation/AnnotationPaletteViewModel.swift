import CoreGraphics
import Combine

class AnnotationPaletteViewModel: ObservableObject {
    weak var parentViewModel: AnnotationViewModel? {
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
        parentViewModel?.$isMinimized.sink(receiveValue: { [weak self] isMinimized in
            self?.isMinimized = isMinimized
        }).store(in: &cancellables)
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

    func didSelectHandwritingButton() {
        guard parentViewModel?.isEditing ?? false else {
            return
        }
        handwritingIsSelected = true
        parentViewModel?.appendHandwritingPartIfNecessary()
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

    func didSelectMinimizeOrMaximizeButton() {
        let isNowMinimized = !isMinimized
        if isNowMinimized {
            enterMinimizedMode()
        } else {
            enterMaximizedMode()
        }
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

        if selectedPart is AnnotationHandwritingViewModel {
            handwritingIsSelected = true
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
