import AnnotatoSharedLibrary
import Foundation
import Combine

class DocumentsPersistenceManager {
    private let webSocketManager: WebSocketManager?
    private let rootPersistenceManager: RootPersistenceManager

    private let remoteDocumentsPersistence: RemoteDocumentsPersistence
    private let localDocumentsPersistence = LocalDocumentsPersistence()
    private var cancellables: Set<AnyCancellable> = []

    @Published private(set) var newDocument: Document?
    @Published private(set) var updatedDocument: Document?
    @Published private(set) var deletedDocument: Document?

    init(webSocketManager: WebSocketManager?) {
        self.webSocketManager = webSocketManager
        self.rootPersistenceManager = RootPersistenceManager(webSocketManager: webSocketManager)
        self.remoteDocumentsPersistence = RemoteDocumentsPersistence(
            webSocketManager: webSocketManager
        )

        setUpSubscribers()
    }

    func getOwnDocuments(userId: String) async -> [Document]? {
        let remoteOwnDocuments = await remoteDocumentsPersistence.getOwnDocuments(userId: userId)
        guard remoteOwnDocuments != nil else {
            return localDocumentsPersistence.getOwnDocuments(userId: userId)
        }
        return remoteOwnDocuments
    }

    func getSharedDocuments(userId: String) async -> [Document]? {
        let remoteSharedDocuments = await remoteDocumentsPersistence.getSharedDocuments(userId: userId)
        guard remoteSharedDocuments != nil else {
            return localDocumentsPersistence.getSharedDocuments(userId: userId)
        }
        return remoteSharedDocuments
    }

    func getDocument(documentId: UUID) async -> Document? {
        let remoteDocument = await remoteDocumentsPersistence.getDocument(documentId: documentId)
        guard remoteDocument != nil else {
            return localDocumentsPersistence.getDocument(documentId: documentId)
        }
        return remoteDocument
    }

    func createDocument(document: Document) async -> Document? {
        let remoteCreatedDocument = await remoteDocumentsPersistence
            .createDocument(document: document)

        if remoteCreatedDocument == nil {
            document.setCreatedAt()
        }

        return localDocumentsPersistence.createDocument(document: remoteCreatedDocument ?? document)
    }

    func updateDocument(document: Document) async -> Document? {
        _ = await remoteDocumentsPersistence.updateDocument(document: document)

        document.setUpdatedAt()
        return localDocumentsPersistence.updateDocument(document: document)
    }

    func deleteDocument(document: Document) async -> Document? {
        _ = await remoteDocumentsPersistence.deleteDocument(document: document)

        return nil
    }

    func deleteDocumentLocally(document: Document) async -> Document? {
        localDocumentsPersistence.deleteDocument(document: document)
    }
}

// MARK: Websocket
extension DocumentsPersistenceManager {
    private func setUpSubscribers() {
        rootPersistenceManager.$crudDocumentMessage.sink { [weak self] message in
            guard let message = message else {
                return
            }

            self?.handleIncomingMessage(message: message)
        }.store(in: &cancellables)
    }

    private func handleIncomingMessage(message: Data) {
        guard let decodedMessage = decodeData(data: message) else {
            return
        }

        let document = decodedMessage.document
        let senderId = decodedMessage.senderId
        let messageSubtype = decodedMessage.subtype

        guard senderId != AuthViewModel().currentUser?.id else {
            return
        }

        Task {
            // NOTE: Documents are hard deleted from local storage
            if messageSubtype == .deleteDocument {
                _ = localDocumentsPersistence.deleteDocument(document: document)
            } else {
                _ = localDocumentsPersistence.createOrUpdateDocument(document: document)
            }
        }

        publishDocument(messageSubtype: messageSubtype, document: document)
    }

    private func decodeData(data: Data) -> AnnotatoCudDocumentMessage? {
        do {
            let decodedMessage = try JSONCustomDecoder().decode(AnnotatoCudDocumentMessage.self, from: data)
            return decodedMessage
        } catch {
            AnnotatoLogger.error(
                "When decoding data. \(error.localizedDescription).",
                context: "DocumentsPersistenceManager::decodeData"
            )
            return nil
        }
    }

    private func publishDocument(messageSubtype: AnnotatoCudDocumentMessageType, document: Document) {
        resetPublishedAttributes()

        switch messageSubtype {
        case .createDocument:
            newDocument = document
            AnnotatoLogger.info("Document was created. \(document)")
        case .updateDocument:
            updatedDocument = document
            AnnotatoLogger.info("Document was updated. \(document)")
        case .deleteDocument:
            deletedDocument = document
            AnnotatoLogger.info("Document was deleted. \(document)")
        }
    }

    private func resetPublishedAttributes() {
        newDocument = nil
        updatedDocument = nil
        deletedDocument = nil
    }
}
