import Vapor
import Fluent
import AnnotatoSharedLibrary

struct AnnotationsDataAccess {
    static func create(db: Database, annotation: Annotation) async throws -> Annotation {
        let annotationEntity = AnnotationEntity.fromModel(annotation)

        try await annotationEntity.create(on: db).get()

        return Annotation.fromManagedEntity(annotationEntity)
    }
}
