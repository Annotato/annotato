import Foundation
import AnnotatoSharedLibrary

struct LocalDocumentsPersistence: DocumentsPersistence {
    private let localDocumentEntityDataAccess = LocalDocumentEntityDataAccess()

    func getOwnDocuments(userId: String) -> [Document]? {
        guard let documentEntities = localDocumentEntityDataAccess.listOwn(userId: userId) else {
            AnnotatoLogger.error("When getting own document.",
                                 context: "LocalDocumentsPersistence::getOwnDocuments")
            return nil
        }

        return documentEntities.map(Document.fromManagedEntity)
    }

    func getSharedDocuments(userId: String) -> [Document]? {
        guard let documentEntities = localDocumentEntityDataAccess.listShared(userId: userId) else {
            AnnotatoLogger.error("When getting shared document.",
                                 context: "LocalDocumentsPersistence::getSharedDocuments")
            return nil
        }

        return documentEntities.map(Document.fromManagedEntity)
    }

    func getDocument(documentId: UUID) -> Document? {
        guard let readDocumentEntity = localDocumentEntityDataAccess.read(documentId: documentId,
                                                                          withDeleted: false) else {
            AnnotatoLogger.error("When reading document.",
                                 context: "LocalDocumentsPersistence::getDocument")
            return nil
        }

        return Document.fromManagedEntity(readDocumentEntity)
    }

    func createDocument(document: Document) -> Document? {
        guard let newDocumentEntity = localDocumentEntityDataAccess.create(document: document) else {
            AnnotatoLogger.error("When creating document.",
                                 context: "LocalDocumentsPersistence::createDocument")
            return nil
        }

        return Document.fromManagedEntity(newDocumentEntity)
    }

    func updateDocument(document: Document) -> Document? {
        guard let updatedDocumentEntity = localDocumentEntityDataAccess
            .update(documentId: document.id, document: document) else {
            AnnotatoLogger.error("When updating document.",
                                 context: "LocalDocumentsPersistence::updateDocument")
            return nil
        }

        return Document.fromManagedEntity(updatedDocumentEntity)
    }

    func deleteDocument(document: Document) -> Document? {
        guard let deletedDocument = localDocumentEntityDataAccess
            .delete(documentId: document.id, document: document) else {
            AnnotatoLogger.error("When deleting document.",
                                 context: "LocalDocumentsPersistence::deleteDocument")
            return nil
        }

        return Document.fromManagedEntity(deletedDocument)
    }

    func createOrUpdateDocument(document: Document) -> Document? {
        if localDocumentEntityDataAccess.read(documentId: document.id,
                                              withDeleted: true) != nil {
            return updateDocument(document: document)
        } else {
            return createDocument(document: document)
        }
    }

    func createOrUpdateDocuments(documents: [Document]) -> [Document]? {
        documents.compactMap({ document in
            createOrUpdateDocument(document: document)
        })
    }
}
