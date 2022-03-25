import FluentKit
import AnnotatoSharedLibrary

struct DocumentSharesDataAccess {
    static func create(db: Database, documentShare: DocumentShare) async throws -> DocumentShare {
        let existingDocumentShare = await findByDocumentIdAndRecipientId(db: db, documentShare: documentShare)

        if let existingDocumentShare = existingDocumentShare {
            throw AnnotatoError.modelAlreadyExists(
                modelType: String(describing: DocumentShareEntity.self),
                modelId: existingDocumentShare.documentId
            )
        }

        let documentShareEntity = DocumentShareEntity.fromModel(documentShare)

        try await db.transaction { tx in
            try await documentShareEntity.customCreate(on: tx)
        }

        return DocumentShare.fromManagedEntity(documentShareEntity)
    }

    // NOTE: DocumentShare is unique on (documentId, recipientId)
    static func findByDocumentIdAndRecipientId(db: Database, documentShare: DocumentShare) async -> DocumentShare? {
        guard let documentShareEntity = try? await DocumentShareEntity
            .query(on: db)
            .filter(\.$documentEntity.$id == documentShare.documentId)
            .filter(\.$recipientId == documentShare.recipientId)
            .first()
            .get()
        else {
            return nil
        }

        return DocumentShare.fromManagedEntity(documentShareEntity)
    }
}
