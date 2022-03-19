import Foundation
import OpenCombine

public final class Annotation: Codable, Timestampable, ObservableObject {
    public let id: UUID
    public private(set) var width: Double
    public private(set) var parts: [AnnotationPart]
    public private(set) var selectionBox: SelectionBox
    public let ownerId: String
    public let documentId: UUID
    public var createdAt: Date?
    public var updatedAt: Date?
    public var deletedAt: Date?

    private var texts: [AnnotationText] {
        parts.compactMap { $0 as? AnnotationText }
    }

    private var handwritings: [AnnotationHandwriting] {
        parts.compactMap { $0 as? AnnotationHandwriting }
    }

    var nonDeletedParts: [AnnotationPart] {
        parts.filter({ !$0.isDeleted })
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
        try container.encode(texts, forKey: .texts)
        try container.encode(handwritings, forKey: .handwritings)
    }

    public func clone() -> Annotation {
        let clonedSelectionBox = selectionBox.clone()
        let clonedParts: [AnnotationPart] = texts.map({ $0.clone() }) + handwritings.map({ $0.clone() })

        return Annotation(origin: origin, width: width, parts: clonedParts, selectionBox: clonedSelectionBox,
                          ownerId: ownerId, documentId: documentId, id: UUID(),
                          createdAt: createdAt, updatedAt: updatedAt, deletedAt: deletedAt)
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
        guard let lastPart = nonDeletedParts.last else {
            return
        }

        removePartIfPossible(part: lastPart)

        // The current last part is what we want, return
        if let currentLastPart = nonDeletedParts.last as? AnnotationText {
            if currentLastPart.type == .plainText {
                return
            }
        }

        addPlainTextPart()
    }

    public func appendMarkdownPartIfNecessary() {
        guard let lastPart = nonDeletedParts.last else {
            return
        }

        removePartIfPossible(part: lastPart)

        // The current last part is what we want, return
        if let currentLastPart = nonDeletedParts.last as? AnnotationText {
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
            order: nonDeletedParts.count,
            annotationId: id, id: UUID()
        )
    }

    private func makeNewMarkdownPart() -> AnnotationText {
        AnnotationText(
            type: .markdown,
            content: "",
            height: 30.0,
            order: nonDeletedParts.count,
            annotationId: id,
            id: UUID()
        )
    }

    private func makeNewHandwritingPart() -> AnnotationHandwriting {
        AnnotationHandwriting(
            order: nonDeletedParts.count,
            height: 150.0,
            annotationId: id,
            handwriting: Data(),
            id: UUID()
        )
    }

    // Note: Each annotation should have at least 1 part
    private func canRemovePart(part: AnnotationPart) -> Bool {
        part.isEmpty && nonDeletedParts.count > 1
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
        nonDeletedParts.enumerated().forEach { idx, part in
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
        nonDeletedParts.enumerated().allSatisfy { idx, part in
            part.order == idx
        }
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
    public func setCreatedAt(to createdAt: Date = Date()) {
        self.createdAt = createdAt
        selectionBox.setCreatedAt(to: createdAt)
        for part in parts {
            part.setCreatedAt(to: createdAt)
        }

        setUpdatedAt(to: createdAt)
    }

    public func setUpdatedAt(to updatedAt: Date = Date()) {
        self.updatedAt = updatedAt
        selectionBox.setUpdatedAt(to: updatedAt)
        for part in parts {
            part.setUpdatedAt(to: updatedAt)
        }
    }

    public func setDeletedAt(to deletedAt: Date = Date()) {
        self.deletedAt = deletedAt
        selectionBox.setDeletedAt(to: deletedAt)
        for part in parts {
            part.setDeletedAt(to: deletedAt)
        }

        setUpdatedAt(to: deletedAt)
    }
}

extension Annotation: Equatable {
    public static func == (lhs: Annotation, rhs: Annotation) -> Bool {
        let partsAreEqual = Set(lhs.texts) == Set(rhs.texts) &&
            Set(lhs.handwritings) == Set(rhs.handwritings)

        return lhs.id == rhs.id &&
            lhs.width == rhs.width &&
            partsAreEqual &&
            lhs.selectionBox == rhs.selectionBox &&
            lhs.ownerId == rhs.ownerId &&
            lhs.documentId == rhs.documentId
    }
}

extension Annotation: Hashable {
    public func hash(into hasher: inout Hasher) {
        hasher.combine(id)
        hasher.combine(width)
        hasher.combine(Set(texts))
        hasher.combine(Set(handwritings))
        hasher.combine(selectionBox)
        hasher.combine(ownerId)
        hasher.combine(documentId)
    }
}
