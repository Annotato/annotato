import Foundation
import CoreGraphics
import Combine

class AnnotationMarkdownViewModel: AnnotationPartViewModel, ObservableObject {
    weak var parentViewModel: AnnotationViewModel?

    private(set) var id: UUID
    private(set) var content: String
    private(set) var origin: CGPoint
    private(set) var width: Double
    internal var height: Double

    @Published private(set) var isEditing = false
    @Published private(set) var isRemoved = false
    var isEmpty: Bool {
        content.isEmpty
    }

    init(id: UUID, content: String, width: Double, height: Double, origin: CGPoint = .zero) {
        self.id = id
        self.content = content
        self.origin = origin
        self.width = width
        self.height = height
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
        self.content = newContent
    }

    func remove() {
        isRemoved = true
    }
}

extension AnnotationMarkdownViewModel {
    var editFrame: CGRect {
        CGRect(x: .zero, y: .zero, width: width, height: height)
    }
}
