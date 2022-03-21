import Foundation
import CoreGraphics

public final class Annotation: Codable {
    public let id: UUID
    public private(set) var origin: CGPoint
    public private(set) var width: Double
    public private(set) var parts: [AnnotationPart]
    public let ownerId: String
    public let documentId: UUID

    public required init(
        origin: CGPoint,
        width: Double,
        parts: [AnnotationPart],
        ownerId: String,
        documentId: UUID,
        id: UUID? = nil
    ) {
        self.id = id ?? UUID()
        self.origin = origin
        self.width = width
        self.parts = parts
        self.ownerId = ownerId
        self.documentId = documentId
    }
    
    private enum CodingKeys: String, CodingKey {
        case id
        case origin
        case width
        case texts
        case ownerId
        case documentId
    }
    
    public init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        id = try container.decode(UUID.self, forKey: .id)
        origin = try container.decode(CGPoint.self, forKey: .origin)
        width = try container.decode(Double.self, forKey: .width)
        ownerId = try container.decode(String.self, forKey: .ownerId)
        documentId = try container.decode(UUID.self, forKey: .documentId)
        
        // Note: AnnotationPart protocol has to be split into concrete types to decode
        parts = []
        let texts = try container.decode([AnnotationText].self, forKey: .texts)
        parts.append(contentsOf: texts)
    }
    
    public func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        try container.encode(id, forKey: .id)
        try container.encode(origin, forKey: .origin)
        try container.encode(width, forKey: .width)
        try container.encode(ownerId, forKey: .ownerId)
        try container.encode(documentId, forKey: .documentId)
        
        // Note: AnnotationPart protocol has to be split into concrete types to encode
        let texts = parts.compactMap({ $0 as? AnnotationText })
        try container.encode(texts, forKey: .texts)
    }
}

extension Annotation: CustomDebugStringConvertible {
    public var debugDescription: String {
        "Annotation(id: \(id), origin: \(origin), width: \(width), parts: \(parts), ownerId: \(ownerId), documentId: \(documentId))"
    }
}
