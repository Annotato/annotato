import Vapor
import Fluent
import Foundation
import AnnotatoSharedLibrary

struct DocumentSharesDataAccess {
    static func create(db: Database, documentShare: DocumentShare) async throws -> DocumentShare {
        let existingDocumentShare = try await findByDocumentIdAndRecipientId(db: db, documentShare: documentShare)

        if let existingDocumentShare = existingDocumentShare {
            throw AnnotatoError.modelAlreadyExists(
                modelType: String(describing: DocumentShareEntity.self),
                modelId: existingDocumentShare.documentId
            )
        }

        let document = try await DocumentsDataAccess.read(db: db, documentId: documentShare.documentId)

        if document.ownerId == documentShare.recipientId {
            throw DocumentShareError.sharingWithSelf(documentShare: documentShare, requestType: .create)
        }

        let documentShareEntity = DocumentShareEntity.fromModel(documentShare)

        try await db.transaction { tx in
            try await documentShareEntity.customCreate(on: tx)
        }

        return DocumentShare.fromManagedEntity(documentShareEntity)
    }

    // NOTE: DocumentShare is unique on (documentId, recipientId)
    static func findByDocumentIdAndRecipientId(
        db: Database,
        documentShare: DocumentShare
    ) async throws -> DocumentShare? {
        guard let documentShareEntity = try await DocumentShareEntity
            .query(on: db)
            .filter(\.$documentEntity.$id == documentShare.documentId)
            .filter(\.$recipientId == documentShare.recipientId)
            .withDeleted()
            .first().get()
        else {
            return nil
        }

        return DocumentShare.fromManagedEntity(documentShareEntity)
    }

    static func findAllRecipientsUsingDocumentId(db: Database, documentId: UUID) async throws -> [DocumentShare] {
        let documentShareEntities = try await DocumentShareEntity
            .query(on: db)
            .filter(\.$documentEntity.$id == documentId)
            .withDeleted()
            .all().get()

        return documentShareEntities.map(DocumentShare.fromManagedEntity)
    }
}
