import Foundation
import AnnotatoSharedLibrary

class DocumentListViewModel {
    private let documentsPersistenceManager: DocumentsPersistenceManager

    private let pdfStorageManager = PDFStorageManager()

    init(webSocketManager: WebSocketManager?) {
        self.documentsPersistenceManager = DocumentsPersistenceManager(webSocketManager: webSocketManager)
    }

    func importDocument(selectedFileUrl: URL, completion: @escaping (Document?) -> Void) {
        let doesFileExist = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first != nil
        guard doesFileExist else {
            return
        }

        guard let ownerId = AuthViewModel().currentUser?.id else {
            return
        }

        Task {
            let document = Document(name: selectedFileUrl.lastPathComponent, ownerId: ownerId)
            pdfStorageManager.uploadPdf(
                fileSystemUrl: selectedFileUrl, fileName: document.id.uuidString
            )

            let createdDocument = await documentsPersistenceManager.createDocument(document: document)

            completion(createdDocument)
        }
    }
}
