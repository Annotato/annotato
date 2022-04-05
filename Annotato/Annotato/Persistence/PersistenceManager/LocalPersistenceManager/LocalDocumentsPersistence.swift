import Foundation
import AnnotatoSharedLibrary

struct LocalDocumentsPersistence: DocumentsPersistence {
    func getOwnDocuments(userId: String) -> [Document]? {
        guard let documentEntities = LocalDocumentEntityDataAccess.listOwn(userId: userId) else {
            AnnotatoLogger.error("When getting own document.",
                                 context: "LocalDocumentsPersistence::getOwnDocuments")
            return nil
        }

        return documentEntities.map(Document.fromManagedEntity)
    }

    func getSharedDocuments(userId: String) -> [Document]? {
        guard let documentEntities = LocalDocumentEntityDataAccess.listShared(userId: userId) else {
            AnnotatoLogger.error("When getting shared document.",
                                 context: "LocalDocumentsPersistence::getSharedDocuments")
            return nil
        }

        return documentEntities.map(Document.fromManagedEntity)
    }

    func getDocument(documentId: UUID) -> Document? {
        guard let readDocumentEntity = LocalDocumentEntityDataAccess.read(documentId: documentId,
                                                                          withDeleted: false) else {
            AnnotatoLogger.error("When reading document.",
                                 context: "LocalDocumentsPersistence::getDocument")
            return nil
        }

        return Document.fromManagedEntity(readDocumentEntity)
    }

    func createDocument(document: Document) -> Document? {
        print("creating document")
        guard let newDocumentEntity = LocalDocumentEntityDataAccess.create(document: document) else {
            AnnotatoLogger.error("When creating document.",
                                 context: "LocalDocumentsPersistence::createDocument")
            return nil
        }

        return Document.fromManagedEntity(newDocumentEntity)
    }

    func updateDocument(document: Document) -> Document? {
        print("updating document")
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

    func createOrUpdateDocumentForLocal(document: Document) -> Document? {
        print("In local documents persistence, creating or updating this document")
        if LocalDocumentEntityDataAccess.read(documentId: document.id,
                                              withDeleted: true) != nil {
            print("document exists")
            return updateDocument(document: document)
        } else {
            print("document doesn't exist")
            return createDocument(document: document)
        }
    }
}
