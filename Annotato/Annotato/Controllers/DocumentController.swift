import Foundation

struct DocumentController {
    static func loadOwnDocuments(userId: String) async -> [DocumentListViewModel] {
        let documents = await AnnotatoPersistenceWrapper.currentPersistenceService.getOwnDocuments(userId: userId)
        guard let documents = documents else {
            return []
        }

        return documents
            .filter { !$0.isDeleted }
            .map { DocumentListViewModel(document: $0, isShared: false) }
    }

    static func loadSharedDocuments(userId: String) async -> [DocumentListViewModel] {
        let documents = await AnnotatoPersistenceWrapper.currentPersistenceService.getSharedDocuments(userId: userId)
        guard let documents = documents else {
            return []
        }

        return documents
            .filter { !$0.isDeleted }
            .map { DocumentListViewModel(document: $0, isShared: true) }
    }

    static func loadAllDocuments(userId: String) async -> [DocumentListViewModel] {
        let ownDocuments = await loadOwnDocuments(userId: userId)
        let sharedDocuments = await loadSharedDocuments(userId: userId)
        let allDocuments = ownDocuments + sharedDocuments
        let sortedDocuments = allDocuments.sorted(by: { $0.name < $1.name })
        return sortedDocuments
    }

    static func loadDocumentWithDeleted(documentId: UUID) async -> DocumentViewModel? {
        let document = await AnnotatoPersistenceWrapper.currentPersistenceService.getDocument(documentId: documentId)
        guard let document = document else {
            return nil
        }

        return DocumentViewModel(model: document)
    }

    @discardableResult static func updateDocumentWithDeleted(document: DocumentViewModel) async -> DocumentViewModel? {
        let updatedDocument = await AnnotatoPersistenceWrapper
            .currentPersistenceService.updateDocument(document: document.model)
        guard let updatedDocument = updatedDocument else {
            return nil
        }

        return DocumentViewModel(model: updatedDocument)
    }
}
