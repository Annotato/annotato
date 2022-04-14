import Foundation
import Combine
import CoreGraphics

public final class SelectionBox: Codable, Timestampable, ObservableObject {
    public let id: UUID
    public let startPoint: CGPoint
    public var annotationId: UUID
    public var createdAt: Date?
    public var updatedAt: Date?
    public var deletedAt: Date?

    @Published public private(set) var endPoint: CGPoint

    public required init(
        startPoint: CGPoint,
        endPoint: CGPoint,
        annotationId: UUID,
        id: UUID? = nil,
        createdAt: Date? = nil,
        updatedAt: Date? = nil,
        deletedAt: Date? = nil
    ) {
        self.id = id ?? UUID()
        self.startPoint = startPoint
        self.endPoint = endPoint
        self.annotationId = annotationId
        self.createdAt = createdAt
        self.updatedAt = updatedAt
        self.deletedAt = deletedAt
    }

    public func setEndPoint(to newEndPoint: CGPoint) {
        self.endPoint = newEndPoint
    }

    private enum CodingKeys: String, CodingKey {
        case id
        case startPoint
        case endPoint
        case annotationId
        case createdAt
        case updatedAt
        case deletedAt
    }

    public init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        id = try container.decode(UUID.self, forKey: .id)
        startPoint = try container.decode(CGPoint.self, forKey: .startPoint)
        endPoint = try container.decode(CGPoint.self, forKey: .endPoint)
        annotationId = try container.decode(UUID.self, forKey: .annotationId)
        createdAt = try container.decodeIfPresent(Date.self, forKey: .createdAt)
        updatedAt = try container.decodeIfPresent(Date.self, forKey: .updatedAt)
        deletedAt = try container.decodeIfPresent(Date.self, forKey: .deletedAt)
    }

    public func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        try container.encode(id, forKey: .id)
        try container.encode(startPoint, forKey: .startPoint)
        try container.encode(endPoint, forKey: .endPoint)
        try container.encode(annotationId, forKey: .annotationId)
        try container.encodeIfPresent(createdAt, forKey: .createdAt)
        try container.encodeIfPresent(updatedAt, forKey: .updatedAt)
        try container.encodeIfPresent(deletedAt, forKey: .deletedAt)
    }

    public func clone(clonedAnnotationId: UUID) -> SelectionBox {
        SelectionBox(startPoint: startPoint, endPoint: endPoint, annotationId: clonedAnnotationId,
                     id: UUID(), createdAt: createdAt, updatedAt: updatedAt, deletedAt: deletedAt)
    }
}

extension SelectionBox: CustomStringConvertible {
    public var description: String {
        "SelectionBox(id: \(id), startPoint: \(startPoint), " +
        "endPoint: \(endPoint), annotationId: \(annotationId), " +
        "createdAt: \(String(describing: createdAt)), " +
        "updatedAt: \(String(describing: updatedAt)), " +
        "deleteAt: \(String(describing: deletedAt))"
    }
}

extension SelectionBox: Equatable {
    public static func == (lhs: SelectionBox, rhs: SelectionBox) -> Bool {
        lhs.id == rhs.id &&
        lhs.startPoint == rhs.startPoint &&
        lhs.endPoint == rhs.endPoint &&
        lhs.annotationId == rhs.annotationId
    }
}

extension SelectionBox: Hashable {
    public func hash(into hasher: inout Hasher) {
        hasher.combine(id)
        hasher.combine(startPoint)
        hasher.combine(endPoint)
        hasher.combine(annotationId)
    }
}
