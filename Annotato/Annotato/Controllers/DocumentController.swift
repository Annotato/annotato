import Foundation

struct DocumentController {
    static func loadOwnDocuments(userId: String) async -> [DocumentListViewModel] {
        let documents = await DocumentsAPI().getOwnDocuments(userId: userId)
        guard let documents = documents else {
            return []
        }

        return documents.map { DocumentListViewModel(document: $0, isShared: false) }
    }

    static func loadSharedDocuments(userId: String) async -> [DocumentListViewModel] {
        let documents = await DocumentsAPI().getSharedDocuments(userId: userId)
        guard let documents = documents else {
            return []
        }

        return documents.map { DocumentListViewModel(document: $0, isShared: true) }
    }

    static func loadAllDocuments(userId: String) async -> [DocumentListViewModel] {
        let ownDocuments = await loadOwnDocuments(userId: userId)
        let sharedDocuments = await loadSharedDocuments(userId: userId)
        let allDocuments = ownDocuments + sharedDocuments
        let sortedDocuments = allDocuments.sorted(by: { $0.name < $1.name })
        return sortedDocuments
    }

    static func loadDocument(documentId: UUID) async -> DocumentViewModel? {
        let document = await DocumentsAPI().getDocument(documentId: documentId)
        guard let document = document else {
            return nil
        }

        return DocumentViewModel(model: document)
    }

    @discardableResult static func updateDocument(document: DocumentViewModel) async -> DocumentViewModel? {
        let updatedDocument = await DocumentsAPI().updateDocument(document: document.model)
        guard let updatedDocument = updatedDocument else {
            return nil
        }

        return DocumentViewModel(model: updatedDocument)
    }
}
