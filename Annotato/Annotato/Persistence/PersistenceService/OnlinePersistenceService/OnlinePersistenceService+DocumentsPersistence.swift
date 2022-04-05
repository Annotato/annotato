import AnnotatoSharedLibrary
import Foundation

extension OnlinePersistenceService: DocumentsPersistence {
    func getOwnDocuments(userId: String) async -> [Document]? {
        await remotePersistence.documents.getOwnDocuments(userId: userId)
    }

    func getSharedDocuments(userId: String) async -> [Document]? {
        await remotePersistence.documents.getSharedDocuments(userId: userId)
    }

    func getDocument(documentId: UUID) async -> Document? {
        await remotePersistence.documents.getDocument(documentId: documentId)
    }

    func createDocument(document: Document) async -> Document? {
        guard let createdDocumentRemote = await remotePersistence
            .documents
            .createDocument(document: document) else {
            return nil
        }
        guard let createdDocumentLocal = await localPersistence
            .documents
            .createDocument(document: createdDocumentRemote) else {
            return nil
        }
        return createdDocumentLocal
    }

    func updateDocument(document: Document) async -> Document? {
        guard let updatedDocumentRemote = await remotePersistence.documents.updateDocument(document: document) else {
            return nil
        }
        guard let updatedDocumentLocal = await localPersistence
            .documents
            .updateDocument(document: updatedDocumentRemote) else {
            return nil
        }
        return updatedDocumentLocal
    }

    func deleteDocument(document: Document) async -> Document? {
        guard let deletedDocumentRemote = await remotePersistence.documents.deleteDocument(document: document) else {
            return nil
        }
        guard let deletedDocumentLocal = await localPersistence
            .documents
            .deleteDocument(document: deletedDocumentRemote) else {
            return nil
        }
        return deletedDocumentLocal
    }

    func createOrUpdateDocuments(documents: [Document]) -> [Document]? {
        localPersistence.documents.createOrUpdateDocuments(documents: documents)
    }
}
