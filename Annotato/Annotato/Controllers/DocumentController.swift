import Foundation

struct DocumentController {
    private let documentsPersistenceManager = DocumentsPersistenceManager()

    func loadOwnDocuments(userId: String) async -> [DocumentListCellViewModel] {
        let documents = await documentsPersistenceManager.getOwnDocuments(userId: userId)
        guard let documents = documents else {
            return []
        }

        return documents
            .filter { !$0.isDeleted }
            .map { DocumentListCellViewModel(document: $0, isShared: false) }
    }

    func loadSharedDocuments(userId: String) async -> [DocumentListCellViewModel] {
        let documents = await documentsPersistenceManager.getSharedDocuments(userId: userId)
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
        let document = await documentsPersistenceManager.getDocument(documentId: documentId)
        guard let document = document else {
            return nil
        }

        return DocumentViewModel(model: document)
    }

    /// This function, which is called when we tap the back button in document edit view, will save the
    /// document and all annotations in it,
    /// including deleted annotations, however, it will not save annotations that are still in merge conflict state
    @discardableResult func updateDocumentWithDeleted(document: DocumentViewModel) async -> DocumentViewModel? {
        let updatedDocument = await documentsPersistenceManager.updateDocument(document: document.model)
        guard let updatedDocument = updatedDocument else {
            return nil
        }

        return DocumentViewModel(model: updatedDocument)
    }
}
