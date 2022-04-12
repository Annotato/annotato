import Foundation
import AnnotatoSharedLibrary

class DocumentListViewModel {
    private let documentsPersistenceManager: DocumentsPersistenceManager
    private let documentSharesPersistenceManager: DocumentSharesPersistenceManager

    private let pdfStorageManager = PDFStorageManager()

    @Published private(set) var hasDeletedDocument = false

    init(webSocketManager: WebSocketManager?) {
        self.documentsPersistenceManager = DocumentsPersistenceManager(webSocketManager: webSocketManager)
        self.documentSharesPersistenceManager = DocumentSharesPersistenceManager()
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

    func deleteDocumentForEveryone(viewModel: DocumentListCellViewModel) {
        Task {
            _ = await documentsPersistenceManager.deleteDocument(document: viewModel.document)
            hasDeletedDocument = true
        }
    }

    func deleteDocumentAsNonOwner(viewModel: DocumentListCellViewModel) {
        guard let recipientId = AuthViewModel().currentUser?.id else {
            return
        }

        Task {
            _ = await documentSharesPersistenceManager.deleteDocumentShare(
                document: viewModel.document, recipientId: recipientId)
            hasDeletedDocument = true
        }
    }
}
