import Foundation
import CoreGraphics
import Combine

@available(iOS 13.0, *)
public final class Annotation: Codable, ObservableObject {
    public let id: UUID
    public private(set) var width: Double
    public private(set) var parts: [AnnotationPart]
    public let ownerId: String
    public let documentId: UUID

    @Published public private(set) var origin: CGPoint
    @Published public private(set) var addedTextPart: AnnotationText?
    @Published public private(set) var addedMarkdownPart: AnnotationText?
    @Published public private(set) var removedPart: AnnotationPart?

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

        if parts.isEmpty {
            addInitialPart()
        }
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
        parts.sort(by: { $0.order < $1.order })
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

    public var hasNoParts: Bool {
        self.parts.isEmpty
    }

    private func addInitialPart() {
        let newPart = makeNewPlainTextPart()
        parts.append(newPart)
    }

    public func addPlainTextPart() {
        let newPart = makeNewPlainTextPart()
        parts.append(newPart)
        addedTextPart = newPart
    }

    public func addMarkdownPart() {
        let newPart = makeNewMarkdownPart()
        parts.append(newPart)
        addedMarkdownPart = newPart
    }

    public func appendTextPartIfNecessary() {
        guard let lastPart = parts.last else {
            return
        }

        removePartIfPossible(part: lastPart)

        // The current last part is what we want, return
        if let currentLastPart = parts.last as? AnnotationText {
            if currentLastPart.type == .plainText {
                return
            }
        }

        let newPart = makeNewPlainTextPart()
        parts.append(newPart)
        addedTextPart = newPart
    }

    public func appendMarkdownPartIfNecessary() {
        guard let lastPart = parts.last else {
            return
        }

        removePartIfPossible(part: lastPart)

        // The current last part is what we want, return
        if let currentLastPart = parts.last as? AnnotationText {
            if currentLastPart.type == .markdown {
                return
            }
        }

        let newPart = makeNewMarkdownPart()
        parts.append(newPart)
        addedMarkdownPart = newPart
    }

    public func setOrigin(to newOrigin: CGPoint) {
        self.origin = newOrigin
    }

    private func makeNewPlainTextPart() -> AnnotationText {
        AnnotationText(
            type: .plainText,
            content: "",
            height: 30.0,
            order: parts.count,
            annotationId: id, id: UUID()
        )
    }

    private func makeNewMarkdownPart() -> AnnotationText {
        AnnotationText(
            type: .markdown,
            content: "",
            height: 30.0,
            order: parts.count,
            annotationId: id,
            id: UUID()
        )
    }

    // Note: Each annotation should have at least 1 part
    private func canRemovePart(part: AnnotationPart) -> Bool {
        part.isEmpty && parts.count > 1
    }

    public func removePartIfPossible(part: AnnotationPart) {
        guard canRemovePart(part: part) else {
            return
        }

        part.remove()
        parts.removeAll(where: { $0.id == part.id })
        removedPart = part
    }
}

@available(iOS 13.0, *)
extension Annotation {
    public var partHeights: Double {
        parts.reduce(0, {acc, part in
            acc + part.height
        })
    }
}

@available(iOS 13.0, *)
extension Annotation: CustomDebugStringConvertible {
    public var debugDescription: String {
        "Annotation(id: \(id), origin: \(origin), width: \(width), " +
        "parts: \(parts), ownerId: \(ownerId), documentId: \(documentId))"
    }
}
