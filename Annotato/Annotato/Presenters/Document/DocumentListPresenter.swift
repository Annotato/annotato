import Foundation
import AnnotatoSharedLibrary
import Combine

class DocumentListPresenter {
    private let documentsPersistenceManager: DocumentsPersistenceManager
    private let documentSharesPersistenceManager: DocumentSharesPersistenceManager
    private let pdfStorageManager = PDFStorageManager()

    private(set) var documents: [DocumentListCellPresenter] = []
    private var cancellables: Set<AnyCancellable> = []

    @Published private(set) var hasDeletedDocument = false

    init(webSocketManager: WebSocketManager?) {
        self.documentsPersistenceManager = DocumentsPersistenceManager(webSocketManager: webSocketManager)
        self.documentSharesPersistenceManager = DocumentSharesPersistenceManager()

        setUpSubscribers()
    }

    func loadAllDocuments(userId: String) async {
        let ownDocuments = await documentsPersistenceManager.getOwnDocuments(userId: userId) ?? []
        let sharedDocuments = await documentsPersistenceManager.getSharedDocuments(userId: userId) ?? []

        let ownDocumentPresenters = ownDocuments.filter { !$0.isDeleted }
            .map { DocumentListCellPresenter(document: $0, isShared: false) }
        let sharedDocumentPresenters = sharedDocuments.filter { !$0.isDeleted }
            .map { DocumentListCellPresenter(document: $0, isShared: true) }

        let allDocumentPresenters = ownDocumentPresenters + sharedDocumentPresenters
        documents = allDocumentPresenters.sorted(by: { $0.name < $1.name })
    }

    func importDocument(selectedFileUrl: URL, completion: @escaping (Document?) -> Void) {
        let doesFileExist = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first != nil
        guard doesFileExist else {
            return
        }

        guard let ownerId = AuthPresenter().currentUser?.id else {
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

    func deleteDocumentForEveryone(presenter: DocumentListCellPresenter) {
        Task {
            _ = await documentsPersistenceManager.deleteDocument(document: presenter.document)
            hasDeletedDocument = true
        }
    }

    func deleteDocumentAsNonOwner(presenter: DocumentListCellPresenter) {
        guard let recipientId = AuthPresenter().currentUser?.id else {
            return
        }

        Task {
            _ = await documentSharesPersistenceManager.deleteDocumentShare(
                document: presenter.document, recipientId: recipientId)
            hasDeletedDocument = true
        }
    }
}

extension DocumentListPresenter {
    private func setUpSubscribers() {
        documentsPersistenceManager.$deletedDocument.sink(receiveValue: { [weak self] _ in
            self?.hasDeletedDocument = true
        }).store(in: &cancellables)
    }
}
