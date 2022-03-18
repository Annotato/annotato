import Vapor
import Fluent
import AnnotatoSharedLibrary
import Foundation

struct DocumentsDataAccess {
    static func list(db: Database, userId: String) -> EventLoopFuture<[Document]> {
        db.query(DocumentEntity.self)
            .filter(\.$ownerId == userId)
            .with(\.$annotations)
            .all()
            .map { entities in
                entities.map(Document.fromManagedEntity)
            }
    }

    static func create(db: Database, document: Document) -> EventLoopFuture<Document> {
        let documentEntity = DocumentEntity.fromModel(document)

        return documentEntity.create(on: db)
            .map {
                document.annotations.forEach { annotation in
                    _ = AnnotationsDataAccess.create(db: db, annotation: annotation)
                }
            }
            .flatMap {
                documentEntity.$annotations.load(on: db).map { Document.fromManagedEntity(documentEntity) }
            }
    }

    static func read(db: Database, documentId: UUID) -> EventLoopFuture<Document> {
        // swiftlint:disable:next first_where
        db.query(DocumentEntity.self)
            .filter(\.$id == documentId)
            .with(\.$annotations)
            .first()
            .unwrap(or: AnnotatoError.modelNotFound(requestType: .read,
                                                    modelType: String(describing: Document.self),
                                                    modelId: documentId))
            .map(Document.fromManagedEntity)
    }

    static func update(db: Database, documentId: UUID, document: Document) -> EventLoopFuture<Document> {
        let documentEntity = DocumentEntity.fromModel(document)

        // swiftlint:disable:next first_where
        return db.query(DocumentEntity.self)
            .filter(\.$id == documentId)
            .first()
            .unwrap(or: AnnotatoError.modelNotFound(requestType: .update,
                                                    modelType: String(describing: Document.self),
                                                    modelId: documentId))
            .flatMap { fetchedEntity in
                fetchedEntity.copyPropertiesOf(otherEntity: documentEntity)
                fetchedEntity.$annotations.load(on: db)

                return fetchedEntity.update(on: db)
                    .map { Document.fromManagedEntity(fetchedEntity) }
            }
    }

    static func delete(db: Database, documentId: UUID) -> EventLoopFuture<Document> {
        // swiftlint:disable:next first_where
        db.query(DocumentEntity.self)
            .filter(\.$id == documentId)
            .first()
            .unwrap(or: AnnotatoError.modelNotFound(requestType: .delete,
                                                    modelType: String(describing: Document.self),
                                                    modelId: documentId))
            .flatMap { documentEntity in
                documentEntity.$annotations.load(on: db)
                    .flatMap({
                        documentEntity.annotations.forEach({ $0.delete(on: db) })
                        return documentEntity.delete(on: db).map{ Document.fromManagedEntity(documentEntity) }
                    })
            }
    }
}
