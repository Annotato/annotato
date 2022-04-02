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
}
