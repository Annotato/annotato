import Foundation
import CoreGraphics
import Combine
import AnnotatoSharedLibrary

class AnnotationMarkdownViewModel: AnnotationPartViewModel, ObservableObject {
    weak var parentViewModel: AnnotationViewModel?

    private(set) var model: AnnotationPart
    private(set) var origin: CGPoint
    private(set) var width: Double
    private var cancellables: Set<AnyCancellable> = []

    // TODO: To use abstract class
    var textModel: AnnotationText? {
        model as? AnnotationText
    }
    var id: UUID {
        model.id
    }
    var height: Double {
        model.height
    }
    var content: String {
        textModel?.content ?? ""
    }

    @Published private(set) var isEditing = false
    @Published private(set) var isRemoved = false
    @Published var isSelected = false

    init(model: AnnotationText, width: Double, origin: CGPoint = .zero) {
        self.model = model
        self.width = width
        self.origin = origin

        setUpSubscribers()
    }

    func toView() -> AnnotationPartView {
        AnnotationMarkdownView(viewModel: self)
    }

    func enterEditMode() {
        isEditing = true
    }

    func enterViewMode() {
        isEditing = false
    }

    func setContent(to newContent: String) {
        textModel?.setContent(to: newContent)
    }

    func remove() {
        isRemoved = true
    }

    private func setUpSubscribers() {
        textModel?.$isRemoved.sink(receiveValue: { [weak self] isRemoved in
            self?.isRemoved = isRemoved
        }).store(in: &cancellables)
    }
}

extension AnnotationMarkdownViewModel {
    var editFrame: CGRect {
        CGRect(x: .zero, y: .zero, width: width, height: model.height)
    }
}
