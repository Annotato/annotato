import Foundation
import Combine
import CoreGraphics

public final class SelectionBox: Codable, ObservableObject {
    public let id: UUID
    public private(set) var startPoint: CGPoint
    public let annotationId: UUID
    @Published public private(set) var endPoint: CGPoint

    public required init(startPoint: CGPoint, endPoint: CGPoint, annotationId: UUID, id: UUID? = nil) {
        self.id = id ?? UUID()
        self.startPoint = startPoint
        self.endPoint = endPoint
        self.annotationId = annotationId
    }

    public func setEndPoint(to newEndPoint: CGPoint) {
        endPoint = newEndPoint
    }

    private enum CodingKeys: String, CodingKey {
        case id
        case startPoint
        case endPoint
        case annotationId
    }

    public init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        id = try container.decode(UUID.self, forKey: .id)
        startPoint = try container.decode(CGPoint.self, forKey: .startPoint)
        endPoint = try container.decode(CGPoint.self, forKey: .endPoint)
        annotationId = try container.decode(UUID.self, forKey: .annotationId)
    }

    public func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        try container.encode(id, forKey: .id)
        try container.encode(startPoint, forKey: .startPoint)
        try container.encode(endPoint, forKey: .endPoint)
        try container.encode(annotationId, forKey: .annotationId)
    }
}

extension SelectionBox: CustomStringConvertible {
    public var description: String {
        "SelectionBox(id: \(id), startPoint: \(startPoint), endPoint: \(endPoint), annotationId: \(annotationId)"
    }
}
