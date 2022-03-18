import Foundation

struct DocumentController {
    static func loadDocument(documentId: UUID) async -> DocumentViewModel? {
        print("Inside loadDocument, before await, id is \(documentId)")
        let document = await DocumentsAPI().getDocument(documentId: documentId)
        print("Inside loadDocument, after await, document is \(document)")
        guard let document = document else {
            return nil
        }

        // TODO: Use document.annotations instead of []
        return DocumentViewModel(document: document)
    }
}
