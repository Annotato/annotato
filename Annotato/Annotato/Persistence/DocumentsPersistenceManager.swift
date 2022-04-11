import AnnotatoSharedLibrary
import Foundation
import Combine

class DocumentsPersistenceManager: DocumentsPersistence {
    private let rootPersistenceManager = RootPersistenceManager()

    private let remotePersistence = RemotePersistenceService()
    private let localPersistence = LocalPersistenceService.shared
    private var cancellables: Set<AnyCancellable> = []

    @Published private(set) var newDocument: Document?
    @Published private(set) var updatedDocument: Document?
    @Published private(set) var deletedDocument: Document?

    init() {
        setUpSubscribers()
    }

    func getOwnDocuments(userId: String) async -> [Document]? {
        let remoteOwnDocuments = await remotePersistence.documents.getOwnDocuments(userId: userId)
        guard remoteOwnDocuments != nil else {
            return await localPersistence.documents.getOwnDocuments(userId: userId)
        }
        return remoteOwnDocuments
    }

    func getSharedDocuments(userId: String) async -> [Document]? {
        let remoteSharedDocuments = await remotePersistence.documents.getSharedDocuments(userId: userId)
        guard remoteSharedDocuments != nil else {
            return await localPersistence.documents.getSharedDocuments(userId: userId)
        }
        return remoteSharedDocuments
    }

    func getDocument(documentId: UUID) async -> Document? {
        let remoteDocument = await remotePersistence.documents.getDocument(documentId: documentId)
        guard remoteDocument != nil else {
            return await localPersistence.documents.getDocument(documentId: documentId)
        }
        return remoteDocument
    }

    func createDocument(document: Document) async -> Document? {
        let remoteCreatedDocument = await remotePersistence
            .documents
            .createDocument(document: document)

        if remoteCreatedDocument == nil {
            document.setCreatedAt()
        }

        return await localPersistence.documents.createDocument(document: remoteCreatedDocument ?? document)
    }

    func updateDocument(document: Document) async -> Document? {
        let remoteUpdatedDocument = await remotePersistence.documents.updateDocument(document: document)

        if remoteUpdatedDocument == nil {
            document.setUpdatedAt()
        }

        return await localPersistence.documents.updateDocument(document: remoteUpdatedDocument ?? document)
    }

    func deleteDocument(document: Document) async -> Document? {
        let remoteDeletedDocument = await remotePersistence.documents.deleteDocument(document: document)

        if remoteDeletedDocument == nil {
            document.setDeletedAt()
        }

        return await localPersistence.documents.deleteDocument(document: remoteDeletedDocument ?? document)
    }

    func createOrUpdateDocument(document: Document) -> Document? {
        fatalError("PersistenceManager::createOrUpdateDocument: This function should not be called")
        return nil
    }

    func createOrUpdateDocuments(documents: [Document]) -> [Document]? {
        fatalError("PersistenceManager::createOrUpdateDocuments: This function should not be called")
        return nil
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
            _ = await LocalPersistenceService.shared.documents
                .createOrUpdateDocument(document: document)
        }

        guard senderId != AnnotatoAuth().currentUser?.id else {
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
