import Foundation

struct DocumentController {
    static func loadAllDocuments(userId: String) async -> [DocumentListViewModel] {
        let documents = await DocumentsAPI().getDocuments(userId: userId)
        guard let documents = documents else {
            return []
        }

        return documents.map { DocumentListViewModel(document: $0) }
    }

    static func loadDocument(documentId: UUID) async -> DocumentViewModel? {
        let document = await DocumentsAPI().getDocument(documentId: documentId)
        guard let document = document else {
            return nil
        }

        return DocumentViewModel(model: document)
    }
}
