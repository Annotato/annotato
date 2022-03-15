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

        return documentEntity.create(on: db).map { Document.fromManagedEntity(documentEntity) }
    }

    static func delete(db: Database, documentId: UUID) {
        db.query(DocumentEntity.self)
            .filter(\.$id == documentId)
            .delete()
    }
}
