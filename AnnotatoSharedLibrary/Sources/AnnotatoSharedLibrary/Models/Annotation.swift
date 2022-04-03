import Foundation
import CoreGraphics

public final class Annotation: Codable, ObservableObject {
    public let id: UUID
    public private(set) var width: Double
    public private(set) var parts: [AnnotationPart]
    public private(set) var selectionBox: SelectionBox
    public let ownerId: String
    public let documentId: UUID
    public private(set) var createdAt: Date?
    public private(set) var updatedAt: Date?
    public private(set) var deletedAt: Date?

    public var isDeleted: Bool {
        deletedAt != nil
    }

    @Published public private(set) var origin: CGPoint
    @Published public private(set) var addedTextPart: AnnotationText?
    @Published public private(set) var addedMarkdownPart: AnnotationText?
    @Published public private(set) var addedHandwritingPart: AnnotationHandwriting?
    @Published public private(set) var removedPart: AnnotationPart?

    public required init(
        origin: CGPoint,
        width: Double,
        parts: [AnnotationPart],
        selectionBox: SelectionBox,
        ownerId: String,
        documentId: UUID,
        id: UUID? = nil,
        createdAt: Date? = nil,
        updatedAt: Date? = nil,
        deletedAt: Date? = nil
    ) {
        self.id = id ?? UUID()
        self.origin = origin
        self.width = width
        self.parts = parts
        self.selectionBox = selectionBox
        self.ownerId = ownerId
        self.documentId = documentId
        self.createdAt = createdAt
        self.updatedAt = updatedAt
        self.deletedAt = deletedAt

        if parts.isEmpty {
            addInitialPart()
        }
    }

    private enum CodingKeys: String, CodingKey {
        case id
        case origin
        case width
        case texts
        case selectionBox
        case handwritings
        case ownerId
        case documentId
        case createdAt
        case updatedAt
        case deletedAt
    }

    public init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        id = try container.decode(UUID.self, forKey: .id)
        origin = try container.decode(CGPoint.self, forKey: .origin)
        width = try container.decode(Double.self, forKey: .width)
        ownerId = try container.decode(String.self, forKey: .ownerId)
        documentId = try container.decode(UUID.self, forKey: .documentId)
        selectionBox = try container.decode(SelectionBox.self, forKey: .selectionBox)
        createdAt = try container.decodeIfPresent(Date.self, forKey: .createdAt)
        updatedAt = try container.decodeIfPresent(Date.self, forKey: .updatedAt)
        deletedAt = try container.decodeIfPresent(Date.self, forKey: .deletedAt)

        // Note: AnnotationPart protocol has to be split into concrete types to decode
        parts = []
        let texts = try container.decode([AnnotationText].self, forKey: .texts)
        let handwritings = try container.decode([AnnotationHandwriting].self, forKey: .handwritings)
        parts.append(contentsOf: texts)
        parts.append(contentsOf: handwritings)
        parts.sort(by: { $0.order < $1.order })
    }

    public func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        try container.encode(id, forKey: .id)
        try container.encode(origin, forKey: .origin)
        try container.encode(width, forKey: .width)
        try container.encode(ownerId, forKey: .ownerId)
        try container.encode(documentId, forKey: .documentId)
        try container.encode(selectionBox, forKey: .selectionBox)
        try container.encodeIfPresent(createdAt, forKey: .createdAt)
        try container.encodeIfPresent(updatedAt, forKey: .updatedAt)
        try container.encodeIfPresent(deletedAt, forKey: .deletedAt)

        // Note: AnnotationPart protocol has to be split into concrete types to encode
        let texts = parts.compactMap({ $0 as? AnnotationText })
        try container.encode(texts, forKey: .texts)

        let handwritings = parts.compactMap({ $0 as? AnnotationHandwriting })
        try container.encode(handwritings, forKey: .handwritings)
    }

    public var hasNoParts: Bool {
        self.parts.isEmpty
    }

    private func addInitialPart() {
        checkRepresentation()

        let newPart = makeNewPlainTextPart()
        parts.append(newPart)

        checkRepresentation()
    }

    public func addPlainTextPart() {
        checkRepresentation()

        let newPart = makeNewPlainTextPart()
        parts.append(newPart)
        addedTextPart = newPart

        checkRepresentation()
    }

    public func addMarkdownPart() {
        checkRepresentation()

        let newPart = makeNewMarkdownPart()
        parts.append(newPart)
        addedMarkdownPart = newPart

        checkRepresentation()
    }

    public func addHandwritingPart() {
        checkRepresentation()

        let newPart = makeNewHandwritingPart()
        parts.append(newPart)
        addedHandwritingPart = newPart

        checkRepresentation()
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

        addPlainTextPart()
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

        addMarkdownPart()
    }

    public func appendHandwritingPartIfNecessary() {
        guard let lastPart = parts.last else {
            return
        }

        removePartIfPossible(part: lastPart)

        guard !(lastPart is AnnotationHandwriting) else {
            return
        }

        addHandwritingPart()
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

    private func makeNewHandwritingPart() -> AnnotationHandwriting {
        AnnotationHandwriting(
            order: parts.count,
            height: 150.0,
            annotationId: id,
            handwriting: Data(),
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

        removePart(part: part)
    }

    public func removePart(part: AnnotationPart) {
        checkRepresentation()

        part.remove()
        parts.removeAll(where: { $0.id == part.id })
        removedPart = part

        maintainOrderOfParts()

        checkRepresentation()
    }

    private func maintainOrderOfParts() {
        parts.enumerated().forEach { idx, part in
            part.order = idx
        }
    }
}

// MARK: Representation Invariants
extension Annotation {
    private func checkRepresentation() {
        assert(checkOrderOfParts())
    }

    private func checkOrderOfParts() -> Bool {
        parts.enumerated().allSatisfy { idx, part in
            part.order == idx
        }
    }
}

extension Annotation {
    public var partHeights: Double {
        parts.reduce(0, { acc, part in
            acc + part.height
        })
    }
}

extension Annotation: CustomDebugStringConvertible {
    public var debugDescription: String {
        "Annotation(id: \(id), origin: \(origin), width: \(width), " +
        "parts: \(parts), ownerId: \(ownerId), documentId: \(documentId)), " +
        "createdAt: \(String(describing: createdAt)), " +
        "updatedAt: \(String(describing: updatedAt)), " +
        "deleteAt: \(String(describing: deletedAt))"
    }
}

// MARK: Timestamps
extension Annotation {
    public func setCreatedAt(to createdAt: Date) {
        self.createdAt = createdAt
        selectionBox.setCreatedAt(to: createdAt)
        for part in parts {
            part.setCreatedAt(to: createdAt)
        }
    }

    public func setUpdatedAt(to updatedAt: Date) {
        self.updatedAt = updatedAt
        selectionBox.setUpdatedAt(to: updatedAt)
        for part in parts {
            part.setUpdatedAt(to: updatedAt)
        }
    }

    public func setDeletedAt(to deletedAt: Date) {
        self.deletedAt = deletedAt
        selectionBox.setDeletedAt(to: deletedAt)
        for part in parts {
            part.setDeletedAt(to: deletedAt)
        }
    }
}

extension Annotation: Equatable {
    public static func == (lhs: Annotation, rhs: Annotation) -> Bool {
        lhs.id == rhs.id
    }
}

extension Annotation: Hashable {
    public func hash(into hasher: inout Hasher) {
        hasher.combine(id)
    }
}
