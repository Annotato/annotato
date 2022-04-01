import Foundation
import AnnotatoSharedLibrary

struct LocalDocumentsPersistence: DocumentsPersistence {
    func getOwnDocuments(userId: String) -> [Document]? {
        // TODO: Implementation
        return nil
    }

    func getSharedDocuments(userId: String) -> [Document]? {
        // TODO: Implementation
        return nil
    }

    func getDocument(documentId: UUID) -> Document? {
        guard let readDocumentEntity = LocalDocumentEntityDataAccess.read(documentId: documentId) else {
            AnnotatoLogger.error("When reading document.",
                                 context: "LocalDocumentsPersistence::getDocument")
            return nil
        }

        return Document.fromManagedEntity(readDocumentEntity)
    }

    func createDocument(document: Document) -> Document? {
        guard let newDocumentEntity = LocalDocumentEntityDataAccess.create(document: document) else {
            AnnotatoLogger.error("When creating document.",
                                 context: "LocalDocumentsPersistence::createDocument")
            return nil
        }

        return Document.fromManagedEntity(newDocumentEntity)
    }

    func updateDocument(document: Document) -> Document? {
        guard let updatedDocumentEntity = LocalDocumentEntityDataAccess
            .update(documentId: document.id, document: document) else {
            AnnotatoLogger.error("When updating document.",
                                 context: "LocalDocumentsPersistence::updateDocument")
            return nil
        }

        return Document.fromManagedEntity(updatedDocumentEntity)
    }

    func deleteDocument(document: Document) -> Document? {
        guard let deletedDocument = LocalDocumentEntityDataAccess
            .delete(documentId: document.id, document: document) else {
            AnnotatoLogger.error("When deleting document.",
                                 context: "LocalDocumentsPersistence::deleteDocument")
            return nil
        }

        return Document.fromManagedEntity(deletedDocument)
    }
}
