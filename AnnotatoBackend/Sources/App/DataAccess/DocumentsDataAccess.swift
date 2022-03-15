import Vapor
import Fluent
import AnnotatoSharedLibrary

struct DocumentsDataAccess {
    static func list(db: Database, userId: UUID) -> EventLoopFuture<[Document]> {
        db.query(DocumentEntity.self)
            .filter(\.$ownerId == userId)
            .all()
            .map { entities in
                entities.map(Document.fromManagedEntity)
            }
    }

    static func create(db: Database, document: Document) -> EventLoopFuture<Document> {
        let documentEntity = DocumentEntity.fromModel(document)

        return documentEntity.create(on: db)
            .map { Document.fromManagedEntity(documentEntity) }
    }

    static func read(db: Database, documentId: UUID) -> EventLoopFuture<Document> {
        // swiftlint:disable:next first_where
        db.query(DocumentEntity.self)
            .filter(\.$id == documentId)
            .first()
            .unwrap(or: AnnotatoError.modelNotFound(requestType: .read,
                                                    modelType: String(describing: Document.self),
                                                    modelId: documentId))
            .map(Document.fromManagedEntity)
    }

    static func update(db: Database, document: Document) -> EventLoopFuture<Document> {
        let documentEntity = DocumentEntity.fromModel(document)

        return documentEntity.update(on: db)
            .map { Document.fromManagedEntity(documentEntity) }
    }

    static func delete(db: Database, documentId: UUID) -> EventLoopFuture<Document> {
        db.query(DocumentEntity.self)
            .filter(\.$id == documentId)
            .first()
            .unwrap(or: AnnotatoError.modelNotFound(requestType: .delete,
                                                    modelType: String(describing: Document.self),
                                                    modelId: documentId))
            .flatMap { documentEntity in
                documentEntity.delete(on: db)
                    .map { Document.fromManagedEntity(documentEntity) }
            }
    }
}
