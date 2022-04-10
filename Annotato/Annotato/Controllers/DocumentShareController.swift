import Foundation
import AnnotatoSharedLibrary

struct DocumentShareController {
    private let documentSharesPersistenceManager = DocumentSharesPersistenceManager()

    func createDocumentShare(documentId: UUID) async -> Document? {
        guard let currentUser = AnnotatoAuth().currentUser else {
            return nil
        }

        let documentShare = DocumentShare(documentId: documentId, recipientId: currentUser.uid)

        return await documentSharesPersistenceManager.createDocumentShare(documentShare: documentShare)
    }
}
