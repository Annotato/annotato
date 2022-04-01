import Foundation
import AnnotatoSharedLibrary

struct LocalDocumentEntityDataAccess {
    static let context = LocalPersistenceManager.sharedContext

    static func listOwn(userId: String) -> [DocumentEntity]? {
        let request = DocumentEntity.fetchRequest()
        request.predicate = NSPredicate(format: "ownerId == %@", userId)

        do {
            let documentEntities = try context.fetch(request)

            return DocumentEntity.removeDeletedDocumentEntities(documentEntities)
        } catch {
            AnnotatoLogger.error("When fetching own document entities.",
                                 context: "LocalDocumentEntityDataAccess::listOwn")
            return nil
        }
    }

    static func listShared(userId: String) -> [DocumentEntity]? {
        let request = DocumentEntity.fetchRequest()
        request.predicate = NSPredicate(format: "ownerId <> %@", userId)

        do {
            let documentEntities = try context.fetch(request)

            return DocumentEntity.removeDeletedDocumentEntities(documentEntities)
        } catch {
            AnnotatoLogger.error("When fetching shared document entities.",
                                 context: "LocalDocumentEntityDataAccess::listShared")
            return nil
        }
    }

    static func create(document: Document) -> DocumentEntity? {
        let documentEntity = DocumentEntity.fromModel(document)

        do {
            try context.save()
        } catch {
            AnnotatoLogger.error("When creating document: \(String(describing: error))",
                                 context: "LocalDocumentsPersistence::create")
            return nil
        }

        return documentEntity
    }

    static func read(documentId: UUID) -> DocumentEntity? {
        let request = DocumentEntity.fetchRequest()
        request.predicate = NSPredicate(format: "id == %@", documentId.uuidString)

        do {
            let documentEntities = try context.fetch(request)

            return documentEntities.first
        } catch {
            AnnotatoLogger.error("When fetching document entity.",
                                 context: "LocalDocumentEntityDataAccess::read")
            return nil
        }
    }

    static func update(documentId: UUID, document: Document) -> DocumentEntity? {
        guard let documentEntity = LocalDocumentEntityDataAccess.read(documentId: documentId) else {
            AnnotatoLogger.error("When finding existing document entity.",
                                 context: "LocalDocumentEntityDataAccess::update")
            return nil
        }

        documentEntity.customUpdate(usingUpdatedModel: document)

        do {
            try context.save()
        } catch {
            AnnotatoLogger.error("When updating document entity.",
                                 context: "LocalDocumentEntityDataAccess::update")
            return nil
        }

        return documentEntity
    }

    static func delete(documentId: UUID, document: Document) -> DocumentEntity? {
        // Deleting is the same as updating deletedAt
        return update(documentId: documentId, document: document)
    }
}
