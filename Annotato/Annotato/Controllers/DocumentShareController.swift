import Foundation
import AnnotatoSharedLibrary

struct DocumentShareController {
    static func createDocumentShare(documentId: UUID) async -> DocumentShare? {
        guard let currentUser = AnnotatoAuth().currentUser else {
            return nil
        }

        let documentShare = DocumentShare(documentId: documentId, recipientId: currentUser.uid)

        return await DocumentSharesAPI().createDocumentShare(documentShare: documentShare)
    }
}
