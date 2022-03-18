import Foundation
import CoreGraphics
import Combine

class AnnotationTextViewModel: AnnotationPartViewModel, ObservableObject {
    weak var parentViewModel: AnnotationViewModel?

    private(set) var id: UUID
    private(set) var content: String
    private(set) var origin: CGPoint
    private(set) var width: Double
    var height: Double

    var isEmpty: Bool {
        content.isEmpty
    }

    @Published private(set) var isEditing = false
    @Published private(set) var isRemoved = false
    @Published var isSelected = false

    init(id: UUID, content: String, width: Double, height: Double, origin: CGPoint = .zero) {
        self.id = id
        self.content = content
        self.origin = origin
        self.width = width
        self.height = height
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
        self.content = newContent
    }

    func remove() {
        isRemoved = true
    }
}
