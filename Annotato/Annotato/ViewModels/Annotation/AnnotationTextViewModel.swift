import Foundation

class AnnotationTextViewModel: AnnotationPartViewModel {
    private(set) var id: UUID
    private(set) var content: String
    private(set) var height: Double

    init(id: UUID, content: String, height: Double) {
        self.id = id
        self.content = content
        self.height = height
    }
}
