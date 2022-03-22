import Foundation
import CoreGraphics
import Combine
import AnnotatoSharedLibrary

class AnnotationTextViewModel: AnnotationPartViewModel, ObservableObject {
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

    init(annotationText: AnnotationText, width: Double, origin: CGPoint = .zero) {
        self.model = annotationText
        self.width = width
        self.origin = origin

        setUpSubscribers()
    }

    func toView() -> AnnotationPartView {
        AnnotationTextView(viewModel: self)
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

    private func setUpSubscribers() {
        textModel?.$isRemoved.sink(receiveValue: { [weak self] isRemoved in
            self?.isRemoved = isRemoved
        }).store(in: &cancellables)
    }
}
