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

    private var isMinimizedByUser = true
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

    func enterEditMode() {
        isEditing = true
        parentViewModel?.enterEditMode()
        enterMaximizedMode()
    }

    func enterViewMode() {
        isEditing = false
        parentViewModel?.enterViewMode()

        guard isMinimizedByUser else {
            return
        }

        enterMinimizedMode()
    }

    func didSelectDeleteButton() {
        parentViewModel?.didDelete()
    }

    func didSelectMinimizeOrMaximizeButton() {
        isMinimizedByUser.toggle()

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
