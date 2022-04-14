import Foundation
import AnnotatoSharedLibrary

struct RemoteDocumentsPersistence {
    private static let documentsUrl = "\(RemotePersistenceService.baseAPIUrl)/documents"
    private static let sharedDocumentsUrl = "\(documentsUrl)/shared"

    private let httpService: AnnotatoHTTPService
    private let webSocketManager: WebSocketManager?

    init(webSocketManager: WebSocketManager?) {
        httpService = URLSessionHTTPService()
        self.webSocketManager = webSocketManager
    }

    // MARK: LIST OWN
    func getOwnDocuments(userId: String) async -> [Document]? {
        do {
            let responseData = try await httpService.get(url: RemoteDocumentsPersistence.documentsUrl,
                                                         params: ["userId": userId])
            return try JSONCustomDecoder().decode([Document].self, from: responseData)
        } catch {
            AnnotatoLogger.error("When fetching own documents: \(String(describing: error))")
            return nil
        }
    }

    // MARK: LIST SHARED
    func getSharedDocuments(userId: String) async -> [Document]? {
        do {
            let responseData = try await httpService.get(url: RemoteDocumentsPersistence.sharedDocumentsUrl,
                                                         params: ["userId": userId])
            return try JSONCustomDecoder().decode([Document].self, from: responseData)
        } catch {
            AnnotatoLogger.error("When fetching shared documents: \(String(describing: error))")
            return nil
        }
    }

    // MARK: READ
    func getDocument(documentId: UUID) async -> Document? {
        do {
            let responseData =
                try await httpService.get(url: "\(RemoteDocumentsPersistence.documentsUrl)/\(documentId)")
            return try JSONCustomDecoder().decode(Document.self, from: responseData)
        } catch {
            AnnotatoLogger.error("When fetching document: \(String(describing: error))")
            return nil
        }
    }

    // MARK: CREATE
    func createDocument(document: Document) async -> Document? {
        guard let requestData = encodeDocument(document) else {
            AnnotatoLogger.error("Document was not created",
                                 context: "RemoteDocumentsPersistence::createDocument")
            return nil
        }

        do {
            let responseData =
                try await httpService.post(url: RemoteDocumentsPersistence.documentsUrl, data: requestData)
            return try JSONCustomDecoder().decode(Document.self, from: responseData)
        } catch {
            AnnotatoLogger.error("When creating document: \(String(describing: error))")
            return nil
        }
    }

    // MARK: UPDATE
    func updateDocument(document: Document) async -> Document? {
        guard let senderId = AuthViewModel().currentUser?.id else {
            return nil
        }

        let webSocketMessage = AnnotatoCudDocumentMessage(
            senderId: senderId, subtype: .updateDocument, document: document)

        webSocketManager?.send(message: webSocketMessage)

        return nil
    }

    // MARK: DELETE
    func deleteDocument(document: Document) async -> Document? {
        guard let senderId = AuthViewModel().currentUser?.id else {
            return nil
        }

        let webSocketMessage = AnnotatoCudDocumentMessage(
            senderId: senderId, subtype: .deleteDocument, document: document
        )

        webSocketManager?.send(message: webSocketMessage)

        return nil
    }

    // MARK: DELETE MANY
    func deleteDocuments(documents: [Document]) async -> [Document]? {
        for document in documents {
            _ = await deleteDocument(document: document)
        }

        return nil
    }

    private func encodeDocument(_ document: Document) -> Data? {
        do {
            let data = try JSONCustomEncoder().encode(document)
            return data
        } catch {
            AnnotatoLogger.error("Could not encode Document into JSON. \(String(describing: error))",
                                 context: "RemoteDocumentsPersistence::encodeDocument")
            return nil
        }
    }
}
