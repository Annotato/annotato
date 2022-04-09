import AnnotatoSharedLibrary
import Foundation

extension PersistenceManager: DocumentsPersistence {
    func getOwnDocuments(userId: String) async -> [Document]? {
        let remoteOwnDocuments = await remotePersistence.documents.getOwnDocuments(userId: userId)
        guard remoteOwnDocuments != nil else {
            return await localPersistence.documents.getOwnDocuments(userId: userId)
        }
        return remoteOwnDocuments
    }

    func getSharedDocuments(userId: String) async -> [Document]? {
        let remoteSharedDocuments = await remotePersistence.documents.getSharedDocuments(userId: userId)
        guard remoteSharedDocuments != nil else {
            return await localPersistence.documents.getSharedDocuments(userId: userId)
        }
        return remoteSharedDocuments
    }

    func getDocument(documentId: UUID) async -> Document? {
        let remoteDocument = await remotePersistence.documents.getDocument(documentId: documentId)
        guard remoteDocument != nil else {
            return await localPersistence.documents.getDocument(documentId: documentId)
        }
        return remoteDocument
    }

    func createDocument(document: Document) async -> Document? {
        let remoteCreatedDocument = await remotePersistence
            .documents
            .createDocument(document: document)

        if remoteCreatedDocument == nil {
            document.setCreatedAt()
        }

        return await localPersistence.documents.createDocument(document: remoteCreatedDocument ?? document)
    }

    func updateDocument(document: Document) async -> Document? {
        let remoteUpdatedDocument = await remotePersistence.documents.updateDocument(document: document)

        if remoteUpdatedDocument == nil {
            document.setUpdatedAt()
        }

        return await localPersistence.documents.updateDocument(document: remoteUpdatedDocument ?? document)
    }

    func deleteDocument(document: Document) async -> Document? {
        let remoteDeletedDocument = await remotePersistence.documents.deleteDocument(document: document)

        if remoteDeletedDocument == nil {
            document.setDeletedAt()
        }

        return await localPersistence.documents.deleteDocument(document: remoteDeletedDocument ?? document)
    }

    func createOrUpdateDocument(document: Document) -> Document? {
        fatalError("PersistenceManager::createOrUpdateDocument: This function should not be called")
        return nil
    }

    func createOrUpdateDocuments(documents: [Document]) -> [Document]? {
        fatalError("PersistenceManager::createOrUpdateDocuments: This function should not be called")
        return nil
    }
}
