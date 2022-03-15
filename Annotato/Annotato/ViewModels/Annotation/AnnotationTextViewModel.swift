import Foundation
import CoreGraphics
import Combine

class AnnotationTextViewModel: AnnotationPartViewModel, ObservableObject {
    private(set) var id: UUID
    private(set) var content: String
    private(set) var origin: CGPoint
    private(set) var width: Double
    private(set) var height: Double

    @Published private(set) var isEditing = false

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
}
