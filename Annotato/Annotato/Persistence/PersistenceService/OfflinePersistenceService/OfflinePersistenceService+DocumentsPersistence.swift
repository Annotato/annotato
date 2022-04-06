import AnnotatoSharedLibrary
import Foundation

extension OfflinePersistenceService: DocumentsPersistence {
    func getOwnDocuments(userId: String) async -> [Document]? {
        await localPersistence.documents.getOwnDocuments(userId: userId)
    }

    func getSharedDocuments(userId: String) async -> [Document]? {
        await localPersistence.documents.getSharedDocuments(userId: userId)
    }

    func getDocument(documentId: UUID) async -> Document? {
        await localPersistence.documents.getDocument(documentId: documentId)
    }

    func createDocument(document: Document) async -> Document? {
        document.setCreatedAt(to: Date())
        return await localPersistence.documents.createDocument(document: document)
    }

    func updateDocument(document: Document) async -> Document? {
        document.setUpdatedAt(to: Date())
        return await localPersistence.documents.updateDocument(document: document)
    }

    func deleteDocument(document: Document) async -> Document? {
        document.setDeletedAt(to: Date())
        return await localPersistence.documents.deleteDocument(document: document)
    }

    func createOrUpdateDocument(document: Document) async -> Document? {
        if LocalDocumentEntityDataAccess.read(documentId: document.id,
                                              withDeleted: true) != nil {
            return await updateDocument(document: document)
        } else {
            return await createDocument(document: document)
        }
    }

    func createOrUpdateDocuments(documents: [Document]) async -> [Document]? {
        var documents: [Document] = []
        for document in documents {
            guard let documentToAppend = await self.createOrUpdateDocument(document: document) else {
                return nil
            }
            documents.append(documentToAppend)
        }
        return documents
    }
}
