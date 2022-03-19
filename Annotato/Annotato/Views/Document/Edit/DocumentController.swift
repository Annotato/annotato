import Foundation

struct DocumentController {
    static func loadDocument(documentId: UUID) async -> DocumentViewModel? {
        let document = await DocumentsAPI().getDocument(documentId: documentId)
        guard let document = document else {
            return nil
        }

        return DocumentViewModel(document: document)
    }
}
