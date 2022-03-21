import Foundation

public protocol AnnotationPart: Codable {
    var id: UUID { get }
    var order: Int { get }
    var height: Double { get }
    var annotationId: UUID { get }
}
