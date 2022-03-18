import Vapor
import Fluent
import AnnotatoSharedLibrary

struct AnnotationsDataAccess {
    static func create(db: Database, annotation: Annotation) -> EventLoopFuture<Annotation> {
        let annotationEntity = AnnotationEntity.fromModel(annotation)

        return annotationEntity.create(on: db)
            .map { Annotation.fromManagedEntity(annotationEntity) }
    }
}
