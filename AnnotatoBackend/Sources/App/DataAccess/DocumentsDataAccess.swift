import Vapor
import Fluent
import AnnotatoSharedLibrary

struct DocumentsDataAccess {
    static func list(db: Database, userId: String) async throws -> [Document] {
        let documentEntities = try await DocumentEntity.query(on: db)
            .filter(\.$ownerId == userId)
            .all().get()

        for documentEntity in documentEntities {
            try await documentEntity.loadAssociations(on: db)
        }

        return documentEntities.map(Document.fromManagedEntity)
    }

    static func create(db: Database, document: Document) async throws -> Document {
        let documentEntity = DocumentEntity.fromModel(document)

        try await documentEntity.customCreate(on: db, usingModel: document)
        try await documentEntity.loadAssociations(on: db)

        return Document.fromManagedEntity(documentEntity)
    }

    static func read(db: Database, documentId: UUID) async throws -> Document {
        guard let documentEntity = try await DocumentEntity.find(documentId, on: db).get() else {
            throw AnnotatoError.modelNotFound(requestType: .read,
                                              modelType: String(describing: Document.self),
                                              modelId: documentId)
        }

        try await documentEntity.loadAssociations(on: db)

        return Document.fromManagedEntity(documentEntity)
    }

    static func update(db: Database, documentId: UUID, document: Document) async throws -> Document {
        guard let documentEntity = try await DocumentEntity.find(documentId, on: db).get() else {
            throw AnnotatoError.modelNotFound(requestType: .update,
                                              modelType: String(describing: Document.self),
                                              modelId: documentId)
        }

        try await db.transaction { tx in
            try await documentEntity.customUpdate(on: tx, usingUpdatedModel: document)
        }

        // Load again as there might be new entities created
        try await documentEntity.loadAssociations(on: db)

        return Document.fromManagedEntity(documentEntity)
    }

    static func delete(db: Database, documentId: UUID) async throws -> Document {
        guard let documentEntity = try await DocumentEntity.find(documentId, on: db).get() else {
            throw AnnotatoError.modelNotFound(requestType: .delete,
                                              modelType: String(describing: Document.self),
                                              modelId: documentId)
        }

        try await db.transaction { tx in
            try await documentEntity.customDelete(on: tx)
        }

        return Document.fromManagedEntity(documentEntity)
    }
}
