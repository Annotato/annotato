import Vapor
import Fluent
import Foundation
import AnnotatoSharedLibrary

struct AnnotationDataAccess {
    func listWithDeleted(db: Database, annotationIds: [UUID]) async throws -> [Annotation] {
        let annotationEntities = try await AnnotationEntity
            .query(on: db)
            .filter(\.$id ~~ annotationIds)
            .withDeleted()
            .all().get()

        for annotationEntity in annotationEntities {
            try await annotationEntity.loadAssociationsWithDeleted(on: db)
        }

        return annotationEntities.map(Annotation.fromManagedEntity)
    }

    func listEntitiesCreatedAfterDateWithDeleted(
        db: Database,
        date: Date,
        userId: String
    ) async throws -> [Annotation] {
        let ownDocumentAnnotationEntities = try await AnnotationEntity
            .query(on: db)
            .join(DocumentEntity.self, on: \AnnotationEntity.$documentEntity.$id == \DocumentEntity.$id)
            .filter(DocumentEntity.self, \DocumentEntity.$ownerId == userId)
            .filter(\.$createdAt > date)
            .withDeleted()
            .all().get()

        let sharedDocumentAnnotationEntities = try await AnnotationEntity
            .query(on: db)
            .join(DocumentEntity.self, on: \AnnotationEntity.$documentEntity.$id == \DocumentEntity.$id)
            .join(DocumentShareEntity.self, on: \DocumentEntity.$id == \DocumentShareEntity.$documentEntity.$id)
            .filter(DocumentShareEntity.self, \DocumentShareEntity.$recipientId == userId)
            .filter(\.$createdAt > date)
            .withDeleted()
            .all().get()

        let annotationEntities = ownDocumentAnnotationEntities + sharedDocumentAnnotationEntities

        for annotationEntity in annotationEntities {
            try await annotationEntity.loadAssociationsWithDeleted(on: db)
        }

        return annotationEntities.map(Annotation.fromManagedEntity)
    }

    func listEntitiesUpdatedAfterDateWithDeleted(
        db: Database,
        date: Date,
        userId: String
    ) async throws -> [Annotation] {
        let ownDocumentAnnotationEntities = try await AnnotationEntity
            .query(on: db)
            .join(DocumentEntity.self, on: \AnnotationEntity.$documentEntity.$id == \DocumentEntity.$id)
            .filter(DocumentEntity.self, \DocumentEntity.$ownerId == userId)
            .filter(\.$updatedAt > date)
            .withDeleted()
            .all().get()

        let sharedDocumentAnnotationEntities = try await AnnotationEntity
            .query(on: db)
            .join(DocumentEntity.self, on: \AnnotationEntity.$documentEntity.$id == \DocumentEntity.$id)
            .join(DocumentShareEntity.self, on: \DocumentEntity.$id == \DocumentShareEntity.$documentEntity.$id)
            .filter(DocumentShareEntity.self, \DocumentShareEntity.$recipientId == userId)
            .filter(\.$updatedAt > date)
            .withDeleted()
            .all().get()

        let annotationEntities = ownDocumentAnnotationEntities + sharedDocumentAnnotationEntities

        for annotationEntity in annotationEntities {
            try await annotationEntity.loadAssociationsWithDeleted(on: db)
        }

        return annotationEntities.map(Annotation.fromManagedEntity)
    }

    func create(db: Database, annotation: Annotation) async throws -> Annotation {
        let annotationEntity = AnnotationEntity.fromModel(annotation)

        try await db.transaction { tx in
            try await annotationEntity.customCreate(on: tx, usingModel: annotation)
        }

        try await annotationEntity.loadAssociationsWithDeleted(on: db)

        return Annotation.fromManagedEntity(annotationEntity)
    }

    func read(db: Database, annotationId: UUID) async throws -> Annotation {
        guard let annotationEntity = try await AnnotationEntity.findWithDeleted(annotationId, on: db).get() else {
            throw AnnotatoError.modelNotFound(requestType: .read,
                                              modelType: String(describing: Annotation.self),
                                              modelId: annotationId)
        }

        try await annotationEntity.loadAssociationsWithDeleted(on: db)

        return Annotation.fromManagedEntity(annotationEntity)
    }

    func update(db: Database, annotationId: UUID, annotation: Annotation) async throws -> Annotation {
        guard let annotationEntity = try await AnnotationEntity.findWithDeleted(annotationId, on: db).get() else {
            throw AnnotatoError.modelNotFound(requestType: .update,
                                              modelType: String(describing: Annotation.self),
                                              modelId: annotationId)
        }

        try await db.transaction { tx in
            try await annotationEntity.customUpdate(on: tx, usingUpdatedModel: annotation)
        }

        // Load again as there might be new entities created
        try await annotationEntity.loadAssociationsWithDeleted(on: db)

        return Annotation.fromManagedEntity(annotationEntity)
    }

    func delete(db: Database, annotationId: UUID) async throws -> Annotation {
        guard let annotationEntity = try await AnnotationEntity.findWithDeleted(annotationId, on: db).get() else {
            throw AnnotatoError.modelNotFound(requestType: .delete,
                                              modelType: String(describing: Annotation.self),
                                              modelId: annotationId)
        }

        try await db.transaction { tx in
            try await annotationEntity.customDelete(on: tx)
        }

        // Load again as associations might be deleted
        try await annotationEntity.loadAssociationsWithDeleted(on: db)

        return Annotation.fromManagedEntity(annotationEntity)
    }

    func canFindWithDeleted(db: Database, annotationId: UUID) async -> Bool {
        (try? await AnnotationEntity.findWithDeleted(annotationId, on: db).get()) != nil
    }
}
