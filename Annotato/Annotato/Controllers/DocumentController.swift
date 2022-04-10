import Foundation

struct DocumentController {
    func loadOwnDocuments(userId: String) async -> [DocumentListCellViewModel] {
        let documents = await AnnotatoPersistenceWrapper.currentPersistenceManager.getOwnDocuments(userId: userId)
        guard let documents = documents else {
            return []
        }

        return documents
            .filter { !$0.isDeleted }
            .map { DocumentListCellViewModel(document: $0, isShared: false) }
    }

    func loadSharedDocuments(userId: String) async -> [DocumentListCellViewModel] {
        let documents = await AnnotatoPersistenceWrapper.currentPersistenceManager.getSharedDocuments(userId: userId)
        guard let documents = documents else {
            return []
        }

        return documents
            .filter { !$0.isDeleted }
            .map { DocumentListCellViewModel(document: $0, isShared: true) }
    }

    func loadAllDocuments(userId: String) async -> [DocumentListCellViewModel] {
        let ownDocuments = await loadOwnDocuments(userId: userId)
        let sharedDocuments = await loadSharedDocuments(userId: userId)
        let allDocuments = ownDocuments + sharedDocuments
        let sortedDocuments = allDocuments.sorted(by: { $0.name < $1.name })
        return sortedDocuments
    }

    func loadDocumentWithDeleted(documentId: UUID) async -> DocumentViewModel? {
        let document = await AnnotatoPersistenceWrapper.currentPersistenceManager.getDocument(documentId: documentId)
        guard let document = document else {
            return nil
        }

        return DocumentViewModel(model: document)
    }

    @discardableResult func updateDocumentWithDeleted(document: DocumentViewModel) async -> DocumentViewModel? {
        let updatedDocument = await AnnotatoPersistenceWrapper
            .currentPersistenceManager.updateDocument(document: document.model)
        guard let updatedDocument = updatedDocument else {
            return nil
        }

        return DocumentViewModel(model: updatedDocument)
    }
}
