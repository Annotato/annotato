import AnnotatoSharedLibrary
import Foundation
import Combine

class DocumentsPersistenceManager {
    private let webSocketManager: WebSocketManager?
    private let rootPersistenceManager: RootPersistenceManager

    private let remoteDocumentsPersistence: RemoteDocumentsPersistence
    private let localDocumentsPersistence = LocalDocumentsPersistence()
    private let remoteDocumentSharesPersistence: RemoteDocumentSharesPersistence
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
        self.remoteDocumentSharesPersistence = RemoteDocumentSharesPersistence()

        setUpSubscribers()
    }

    func getOwnDocuments(userId: String) async -> [Document]? {
        let remoteOwnDocuments = await remoteDocumentsPersistence.getOwnDocuments(userId: userId)
        let localOwnDocuments = localDocumentsPersistence.getOwnDocuments(userId: userId)

        if let remoteOwnDocuments = remoteOwnDocuments,
           let localOwnDocuments = localOwnDocuments {
            await pruneRemoteDocuments(localDocuments: localOwnDocuments, serverDocuments: remoteOwnDocuments)
        }

        return localOwnDocuments
    }

    private func pruneRemoteDocuments(localDocuments: [Document], serverDocuments: [Document]) async {
        let conflictResolver = DocumentConflictResolver(
            localModels: localDocuments, serverModels: serverDocuments)
        let documentsConflictResolution = conflictResolver.resolve()
        let serverDelete = documentsConflictResolution.serverDelete
        _ = await remoteDocumentsPersistence.deleteDocuments(documents: serverDelete)
    }

    func getSharedDocuments(userId: String) async -> [Document]? {
        let remoteSharedDocuments = await remoteDocumentsPersistence.getSharedDocuments(userId: userId)
        let localSharedDocuments = localDocumentsPersistence.getSharedDocuments(userId: userId)

        if let remoteSharedDocuments = remoteSharedDocuments,
           let localSharedDocuments = localSharedDocuments {
            await pruneRemoteDocumentShares(
                localDocuments: localSharedDocuments, serverDocuments: remoteSharedDocuments)
        }

        return localSharedDocuments
    }

    private func pruneRemoteDocumentShares(localDocuments: [Document], serverDocuments: [Document]) async {
        guard let recipientId = AuthViewModel().currentUser?.id else {
            return
        }

        let conflictResolver = DocumentConflictResolver(
            localModels: localDocuments, serverModels: serverDocuments)
        let documentsConflictResolution = conflictResolver.resolve()
        let serverDelete = documentsConflictResolution.serverDelete
        let documentIds = serverDelete.map { $0.id }

        _ = await remoteDocumentSharesPersistence.deleteDocumentShares(
            documentIds: documentIds, recipientId: recipientId)
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

        // NOTE: Documents are hard deleted from local storage
        return localDocumentsPersistence.deleteDocument(document: document)
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

        Task {
            // NOTE: Documents are hard deleted from local storage
            if messageSubtype == .deleteDocument {
                _ = localDocumentsPersistence.deleteDocument(document: document)
            } else {
                _ = localDocumentsPersistence.createOrUpdateDocument(document: document)
            }
        }

        guard senderId != AuthViewModel().currentUser?.id else {
            return
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
