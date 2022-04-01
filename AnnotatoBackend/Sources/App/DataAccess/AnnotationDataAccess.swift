import Vapor
import Fluent
import AnnotatoSharedLibrary

struct AnnotationDataAccess {
    static func create(db: Database, annotation: Annotation) async throws -> Annotation {
        let annotationEntity = AnnotationEntity.fromModel(annotation)

        try await db.transaction { tx in
            try await annotationEntity.customCreate(on: tx, usingModel: annotation)
        }

        try await annotationEntity.loadAssociations(on: db)

        return Annotation.fromManagedEntity(annotationEntity)
    }

    static func read(db: Database, annotationId: UUID) async throws -> Annotation {
        guard let annotationEntity = try await AnnotationEntity.find(annotationId, on: db).get() else {
            throw AnnotatoError.modelNotFound(requestType: .read,
                                              modelType: String(describing: Annotation.self),
                                              modelId: annotationId)
        }

        try await annotationEntity.loadAssociations(on: db)

        return Annotation.fromManagedEntity(annotationEntity)
    }

    static func update(db: Database, annotationId: UUID, annotation: Annotation) async throws -> Annotation {
        guard let annotationEntity = try await AnnotationEntity.findIncludingDeleted(annotationId, on: db).get() else {
            throw AnnotatoError.modelNotFound(requestType: .update,
                                              modelType: String(describing: Annotation.self),
                                              modelId: annotationId)
        }

        try await db.transaction { tx in
            try await annotationEntity.customUpdate(on: tx, usingUpdatedModel: annotation)
        }

        // Load again as there might be new entities created
        try await annotationEntity.loadAssociations(on: db)

        return Annotation.fromManagedEntity(annotationEntity)
    }

    static func delete(db: Database, annotationId: UUID) async throws -> Annotation {
        guard let annotationEntity = try await AnnotationEntity.findIncludingDeleted(annotationId, on: db).get() else {
            throw AnnotatoError.modelNotFound(requestType: .delete,
                                              modelType: String(describing: Annotation.self),
                                              modelId: annotationId)
        }

        try await db.transaction { tx in
            try await annotationEntity.customDelete(on: tx)
        }

        return Annotation.fromManagedEntity(annotationEntity)
    }

    static func canFindIncludingDeleted(db: Database, annotationId: UUID) async -> Bool {
        (try? await AnnotationEntity.findIncludingDeleted(annotationId, on: db).get()) != nil
    }
}
