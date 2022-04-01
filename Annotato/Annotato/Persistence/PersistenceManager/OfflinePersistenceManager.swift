import AnnotatoSharedLibrary
import Foundation

struct OfflinePersistenceManager: PersistenceService {
    private let localPersistence: PersistenceManager

    init(localPersistence: PersistenceManager) {
        self.localPersistence = localPersistence
    }

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
        await localPersistence.documents.createDocument(document: document)
    }

    func updateDocument(document: Document) async -> Document? {
        await localPersistence.documents.updateDocument(document: document)
    }

    func deleteDocument(document: Document) async -> Document? {
        await localPersistence.documents.deleteDocument(document: document)
    }

    func createDocumentShare(documentShare: DocumentShare) async -> DocumentShare? {
        await localPersistence.documentShares.createDocumentShare(documentShare: documentShare)
    }
}
