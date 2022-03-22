import FluentKit
import AnnotatoSharedLibrary

final class AnnotationEntity: Model {
    static let schema = "annotations"

    @ID(key: .id)
    var id: UUID?

    @Field(key: "origin_x")
    var originX: Double

    @Field(key: "origin_y")
    var originY: Double

    @Field(key: "width")
    var width: Double

    @Field(key: "owner_id")
    var ownerId: String

    @Parent(key: "document_id")
    var documentEntity: DocumentEntity

    @Children(for: \.$annotationEntity)
    var annotationTextEntities: [AnnotationTextEntity]

    @Timestamp(key: "created_at", on: .create)
    var createdAt: Date?

    @Timestamp(key: "updated_at", on: .update)
    var updatedAt: Date?

    init() { }

    init(
        originX: Double,
        originY: Double,
        width: Double,
        ownerId: String,
        documentId: DocumentEntity.IDValue,
        id: UUID? = nil
    ) {
        self.id = id
        self.originX = originX
        self.originY = originY
        self.width = width
        self.ownerId = ownerId
        self.$documentEntity.id = documentId
    }
}

extension AnnotationEntity: PersistedEntity {
    static func fromModel(_ model: Annotation) -> Self {
        Self(
            originX: model.origin.x,
            originY: model.origin.y,
            width: model.width,
            ownerId: model.ownerId,
            documentId: model.documentId,
            id: model.id
        )
    }
}

extension AnnotationEntity {
    func copyPropertiesOf(otherEntity: AnnotationEntity) {
        precondition(id == otherEntity.id)

        originX = otherEntity.originX
        originY = otherEntity.originY
        width = otherEntity.width
        ownerId = otherEntity.ownerId
        $documentEntity.id = otherEntity.$documentEntity.id
    }
    
    func loadAssociations(on db: Database) async throws {
        try await self.$annotationTextEntities.load(on: db).get()
    }

    func customUpdate(on tx: Database, usingUpdatedModel annotation: Annotation) async throws {
        try await self.loadAssociations(on: tx)
        try await self.pruneOldAssociations(on: tx, using: annotation)
        self.copyPropertiesOf(otherEntity: AnnotationEntity.fromModel(annotation))
        let annotationTexts = annotation.parts.compactMap({ $0 as? AnnotationText })

        for annotationText in annotationTexts {
            if let annotationTextEntity = try await AnnotationTextEntity.find(annotationText.id, on: tx).get() {
                try await annotationTextEntity.customUpdate(on: tx, usingUpdatedModel: annotationText)
            } else {
                try await AnnotationTextEntity.fromModel(annotationText).create(on: tx).get()
            }
        }

        return try await self.update(on: tx).get()
    }

    func customDelete(on tx: Database) async throws {
        try await self.loadAssociations(on: tx)
        
        for textEntity in annotationTextEntities {
            try await textEntity.customDelete(on: tx)
        }
        
        try await self.delete(on: tx).get()
    }

    private func pruneOldAssociations(on tx: Database, using annotation: Annotation) async throws {
        let annotationTexts = annotation.parts.compactMap({ $0 as? AnnotationText })

        for annotationTextEntity in annotationTextEntities where !annotationTexts.contains(where: { $0.id == annotationTextEntity.id }) {
            try await annotationTextEntity.customDelete(on: tx)
        }
    }
}
