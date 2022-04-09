import Vapor
import Fluent
import Foundation
import AnnotatoSharedLibrary

struct DocumentsDataAccess {
    static func listOwn(db: Database, userId: String) async throws -> [Document] {
        let documentEntities = try await DocumentEntity.query(on: db)
            .filter(\.$ownerId == userId)
            .withDeleted()
            .sort(\.$name)
            .all().get()

        for documentEntity in documentEntities {
            try await documentEntity.loadAssociationsWithDeleted(on: db)
        }

        return documentEntities.map(Document.fromManagedEntity)
    }

    static func listShared(db: Database, userId: String) async throws -> [Document] {
        let documentEntities = try await DocumentEntity.query(on: db)
            .join(DocumentShareEntity.self, on: \DocumentEntity.$id == \DocumentShareEntity.$documentEntity.$id)
            .filter(DocumentShareEntity.self, \DocumentShareEntity.$recipientId == userId)
            .withDeleted()
            .sort(\.$name)
            .all().get()

        for documentEntity in documentEntities {
            try await documentEntity.loadAssociationsWithDeleted(on: db)
        }

        return documentEntities.map(Document.fromManagedEntity)
    }

    static func listWithDeleted(db: Database, documentIds: [UUID]) async throws -> [Document] {
        let documentEntities = try await DocumentEntity
            .query(on: db)
            .filter(\.$id ~~ documentIds)
            .withDeleted()
            .all().get()

        for documentEntity in documentEntities {
            try await documentEntity.loadAssociationsWithDeleted(on: db)
        }

        return documentEntities.map(Document.fromManagedEntity)
    }

    static func listEntitiesCreatedAfterDateWithDeleted(
        db: Database,
        date: Date,
        userId: String
    ) async throws -> [Document] {
        let ownDocumentEntities = try await DocumentEntity
            .query(on: db)
            .filter(\.$ownerId == userId)
            .filter(\.$createdAt > date)
            .withDeleted()
            .all().get()

        let sharedDocumentEntities = try await DocumentEntity
            .query(on: db)
            .join(DocumentShareEntity.self, on: \DocumentEntity.$id == \DocumentShareEntity.$documentEntity.$id)
            .filter(DocumentShareEntity.self, \DocumentShareEntity.$recipientId == userId)
            .filter(\.$createdAt > date)
            .withDeleted()
            .all().get()

        let documentEntities = ownDocumentEntities + sharedDocumentEntities

        for documentEntity in documentEntities {
            try await documentEntity.loadAssociationsWithDeleted(on: db)
        }

        return documentEntities.map(Document.fromManagedEntity)
    }

    static func listEntitiesUpdatedAfterDateWithDeleted(
        db: Database,
        date: Date,
        userId: String
    ) async throws -> [Document] {
        let ownDocumentEntities = try await DocumentEntity
            .query(on: db)
            .filter(\.$ownerId == userId)
            .filter(\.$updatedAt > date)
            .withDeleted()
            .all().get()

        let sharedDocumentEntities = try await DocumentEntity
            .query(on: db)
            .join(DocumentShareEntity.self, on: \DocumentEntity.$id == \DocumentShareEntity.$documentEntity.$id)
            .filter(DocumentShareEntity.self, \DocumentShareEntity.$recipientId == userId)
            .filter(\.$updatedAt > date)
            .withDeleted()
            .all().get()

        let documentEntities = ownDocumentEntities + sharedDocumentEntities

        for documentEntity in documentEntities {
            try await documentEntity.loadAssociationsWithDeleted(on: db)
        }

        return documentEntities.map(Document.fromManagedEntity)
    }

    static func create(db: Database, document: Document) async throws -> Document {
        let documentEntity = DocumentEntity.fromModel(document)

        try await db.transaction { tx in
            try await documentEntity.customCreate(on: tx, usingModel: document)
        }

        try await documentEntity.loadAssociationsWithDeleted(on: db)

        return Document.fromManagedEntity(documentEntity)
    }

    static func read(db: Database, documentId: UUID) async throws -> Document {
        guard let documentEntity = try await DocumentEntity.findWithDeleted(documentId, on: db).get() else {
            throw AnnotatoError.modelNotFound(requestType: .read,
                                              modelType: String(describing: Document.self),
                                              modelId: documentId)
        }

        try await documentEntity.loadAssociationsWithDeleted(on: db)

        return Document.fromManagedEntity(documentEntity)
    }

    static func update(db: Database, documentId: UUID, document: Document) async throws -> Document {
        guard let documentEntity = try await DocumentEntity.findWithDeleted(documentId, on: db).get() else {
            throw AnnotatoError.modelNotFound(requestType: .update,
                                              modelType: String(describing: Document.self),
                                              modelId: documentId)
        }

        try await db.transaction { tx in
            try await documentEntity.customUpdate(on: tx, usingUpdatedModel: document)
        }

        // Load again as there might be new entities created
        try await documentEntity.loadAssociationsWithDeleted(on: db)

        return Document.fromManagedEntity(documentEntity)
    }

    static func delete(db: Database, documentId: UUID) async throws -> Document {
        guard let documentEntity = try await DocumentEntity.findWithDeleted(documentId, on: db).get() else {
            throw AnnotatoError.modelNotFound(requestType: .delete,
                                              modelType: String(describing: Document.self),
                                              modelId: documentId)
        }

        try await db.transaction { tx in
            try await documentEntity.customDelete(on: tx)
        }

        // Load again as associations might be deleted
        try await documentEntity.loadAssociationsWithDeleted(on: db)

        return Document.fromManagedEntity(documentEntity)
    }

    static func canFindWithDeleted(db: Database, documentId: UUID) async -> Bool {
        (try? await DocumentEntity.findWithDeleted(documentId, on: db).get()) != nil
    }
}
