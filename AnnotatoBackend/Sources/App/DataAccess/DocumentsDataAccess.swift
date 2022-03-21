import Vapor
import Fluent
import AnnotatoSharedLibrary

struct DocumentsDataAccess {
    static func list(db: Database, userId: String) async throws -> [Document] {
        try await DocumentEntity.query(on: db)
            .filter(\.$ownerId == userId)
            .with(\.$annotations).all().get()
            .map(Document.fromManagedEntity)
    }

    static func create(db: Database, document: Document) async throws -> Document {
        let documentEntity = DocumentEntity.fromModel(document)

        try await documentEntity.create(on: db).get()
        try await documentEntity.$annotations.load(on: db).get()

        return Document.fromManagedEntity(documentEntity)
    }

    static func read(db: Database, documentId: UUID) async throws -> Document {
        guard let documentEntity = try await DocumentEntity.find(documentId, on: db).get() else {
            throw AnnotatoError.modelNotFound(requestType: .read, modelType: String(describing: Document.self), modelId: documentId)
        }
        try await documentEntity.$annotations.load(on: db).get()

        return Document.fromManagedEntity(documentEntity)
    }

    static func update(db: Database, documentId: UUID, document: Document) async throws -> Document {
        guard let documentEntity = try await DocumentEntity.find(documentId, on: db).get() else {
            throw AnnotatoError.modelNotFound(requestType: .update, modelType: String(describing: Document.self), modelId: documentId)
        }

        documentEntity.copyPropertiesOf(otherEntity: DocumentEntity.fromModel(document))
        try await documentEntity.update(on: db).get()
        try await documentEntity.$annotations.load(on: db).get()

        return Document.fromManagedEntity(documentEntity)
    }

    static func delete(db: Database, documentId: UUID) async throws -> Document {
        guard let documentEntity = try await DocumentEntity.find(documentId, on: db).get() else {
            throw AnnotatoError.modelNotFound(requestType: .delete, modelType: String(describing: Document.self), modelId: documentId)
        }

        try await documentEntity.$annotations.load(on: db).get()
        try await documentEntity.delete(on: db).get()

        return Document.fromManagedEntity(documentEntity)
    }
}
