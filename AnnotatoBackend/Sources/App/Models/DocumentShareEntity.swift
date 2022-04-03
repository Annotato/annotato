import Foundation
import FluentKit
import AnnotatoSharedLibrary

final class DocumentShareEntity: Model {
    static let schema = "document_shares"

    @ID(key: .id)
    var id: UUID?

    @Parent(key: "document_id")
    var documentEntity: DocumentEntity

    @Field(key: "recipient_id")
    var recipientId: String

    @Timestamp(key: "created_at", on: .create)
    var createdAt: Date?

    @Timestamp(key: "updated_at", on: .update)
    var updatedAt: Date?

    @Timestamp(key: "deleted_at", on: .delete)
    var deletedAt: Date?

    var isDeleted: Bool {
        deletedAt != nil
    }

    init() { }

    init(
        documentId: DocumentEntity.IDValue,
        recipientId: String,
        id: UUID? = nil,
        createdAt: Date? = nil,
        updatedAt: Date? = nil,
        deletedAt: Date? = nil
    ) {
        self.id = id
        self.$documentEntity.id = documentId
        self.recipientId = recipientId
        self.createdAt = createdAt
        self.updatedAt = updatedAt
        self.deletedAt = deletedAt
    }
}

extension DocumentShareEntity: PersistedEntity {
    static func fromModel(_ model: DocumentShare) -> Self {
        Self(
            documentId: model.documentId,
            recipientId: model.recipientId,
            id: model.id,
            createdAt: model.createdAt,
            updatedAt: model.updatedAt,
            deletedAt: model.deletedAt
        )
    }
}
