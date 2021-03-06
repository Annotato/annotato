import AnnotatoSharedLibrary
import Foundation
import Combine

class DocumentsInteractor {
    private let webSocketManager: WebSocketManager?
    private let rootInteractor: RootInteractor
    private let usersInteractor: UsersInteractor
    private let annotationsInteractor: AnnotationsInteractor
    private let pdfStorageManager = PDFStorageManager()

    private let remoteDocumentsPersistence: RemoteDocumentsPersistence
    private let localDocumentsPersistence = LocalDocumentsPersistence()
    private let remoteDocumentSharesPersistence: RemoteDocumentSharesPersistence
    private var cancellables: Set<AnyCancellable> = []

    @Published private(set) var newDocument: Document?
    @Published private(set) var updatedDocument: Document?
    @Published private(set) var deletedDocument: Document?

    init(webSocketManager: WebSocketManager?) {
        self.webSocketManager = webSocketManager
        self.rootInteractor = RootInteractor(webSocketManager: webSocketManager)
        self.usersInteractor = UsersInteractor()
        self.annotationsInteractor = AnnotationsInteractor(webSocketManager: webSocketManager)
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
            // NOTE: Deletes server documents if corrresponding local documents were deleted while offline
            await pruneRemoteDocuments(localDocuments: localOwnDocuments, serverDocuments: remoteOwnDocuments)
        }

        return localOwnDocuments
    }

    private func pruneRemoteDocuments(localDocuments: [Document], serverDocuments: [Document]) async {
        let conflictResolver = DocumentConflictResolver(
            localModels: localDocuments, serverModels: serverDocuments)
        let documentsConflictResolution = conflictResolver.resolve()

        guard let senderId = usersInteractor.fetchSessionUser()?.id else {
            return
        }
        let serverDelete = documentsConflictResolution.serverDelete
        _ = await remoteDocumentsPersistence.deleteDocuments(documents: serverDelete, senderId: senderId)
    }

    func getSharedDocuments(userId: String) async -> [Document]? {
        let remoteSharedDocuments = await remoteDocumentsPersistence.getSharedDocuments(userId: userId)
        let localSharedDocuments = localDocumentsPersistence.getSharedDocuments(userId: userId)

        if let remoteSharedDocuments = remoteSharedDocuments,
           let localSharedDocuments = localSharedDocuments {
            // NOTE: Deletes server document shares if corrresponding local documents were deleted while offline
            await pruneRemoteDocumentShares(
                localDocuments: localSharedDocuments, serverDocuments: remoteSharedDocuments)
        }

        return localSharedDocuments
    }

    private func pruneRemoteDocumentShares(localDocuments: [Document], serverDocuments: [Document]) async {
        guard let recipientId = usersInteractor.fetchSessionUser()?.id else {
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

    func createDocument(document: Document, selectedFileUrl: URL) async -> Document? {
        pdfStorageManager.uploadPdf(
            fileSystemUrl: selectedFileUrl, fileName: document.id.uuidString
        )

        let remoteCreatedDocument = await remoteDocumentsPersistence
            .createDocument(document: document)

        if remoteCreatedDocument == nil {
            document.setCreatedAt()
        }

        return localDocumentsPersistence.createDocument(document: remoteCreatedDocument ?? document)
    }

    func updateDocument(document: Document) async -> Document? {
        guard let senderId = usersInteractor.fetchSessionUser()?.id else {
            return nil
        }

        _ = await remoteDocumentsPersistence.updateDocument(document: document, senderId: senderId)

        document.setUpdatedAt()
        return localDocumentsPersistence.updateDocument(document: document)
    }

    func deleteDocument(document: Document) async -> Document? {
        guard let senderId = usersInteractor.fetchSessionUser()?.id else {
            return nil
        }

        _ = await remoteDocumentsPersistence.deleteDocument(document: document, senderId: senderId)

        // NOTE: Documents are hard deleted from local storage
        return deleteDocumentLocally(document: document)
    }

    func deleteDocumentLocally(document: Document) -> Document? {
        localDocumentsPersistence.deleteDocument(document: document)
    }

    func getLocalAndRemoteDocument(documentId: UUID) async -> (local: Document?, remote: Document?) {
        let localDocument = localDocumentsPersistence.getDocument(documentId: documentId)
        let remoteDocument = await remoteDocumentsPersistence.getDocument(documentId: documentId)
        return (localDocument, remoteDocument)
    }

    func loadResolvedDocument(documentId: UUID) async -> Document? {
        let localAndRemoteDocumentPair = await getLocalAndRemoteDocument(documentId: documentId)
        guard let localDocument = localAndRemoteDocumentPair.local,
              let serverDocument = localAndRemoteDocumentPair.remote else {
            AnnotatoLogger.error("Could not load from local and remote for conflict resolution")
            return nil
        }

        let resolvedAnnotations = ConflictResolver(localModels: localDocument.annotations,
                                                   serverModels: serverDocument.annotations).resolve()

        await annotationsInteractor.persistConflictResolution(conflictResolution: resolvedAnnotations)

        serverDocument.setAnnotations(annotations: resolvedAnnotations.nonConflictingModels)

        for (conflictIdx, (localAnnotation, serverAnnotation)) in resolvedAnnotations.conflictingModels.enumerated() {
            let newLocalAnnotation = localAnnotation.clone()
            newLocalAnnotation.conflictIdx = conflictIdx
            serverAnnotation.conflictIdx = conflictIdx
            serverDocument.addAnnotation(annotation: newLocalAnnotation)
            serverDocument.addAnnotation(annotation: serverAnnotation)
        }

        return serverDocument
    }
}

// MARK: Websocket
extension DocumentsInteractor {
    private func setUpSubscribers() {
        rootInteractor.$crudDocumentMessage.sink { [weak self] message in
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

        // NOTE: Documents are hard deleted from local storage
        if messageSubtype == .deleteDocument {
            _ = deleteDocumentLocally(document: document)
        } else {
            _ = localDocumentsPersistence.createOrUpdateDocument(document: document)
        }

        guard senderId != usersInteractor.fetchSessionUser()?.id else {
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

        resetPublishedAttributes()
    }

    private func resetPublishedAttributes() {
        newDocument = nil
        updatedDocument = nil
        deletedDocument = nil
    }
}
