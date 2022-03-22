import Foundation

public protocol AnnotationPart: AnyObject, Codable {
    var id: UUID { get }
    var order: Int { get }
    var height: Double { get set }
    var annotationId: UUID { get }
    var isEmpty: Bool { get }

    func remove()
}

extension AnnotationPart {
    public func setHeight(to newHeight: Double) {
        self.height = newHeight
    }
}
