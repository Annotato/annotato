import Foundation
import AnnotatoSharedLibrary

struct RemoteDocumentsPersistence: DocumentsPersistence {
    private static let documentsUrl = "\(RemotePersistenceManager.baseAPIUrl)/documents"
    private static let sharedDocumentsUrl = "\(documentsUrl)/shared"

    private var httpService: AnnotatoHTTPService

    init() {
        httpService = URLSessionHTTPService()
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
        guard let requestData = encodeDocument(document) else {
            AnnotatoLogger.error("Document was not updated",
                                 context: "RemoteDocumentsPersistence::updateDocument")
            return nil
        }

        do {
            let responseData =
                try await httpService.put(url: "\(RemoteDocumentsPersistence.documentsUrl)/\(document.id)",
                                          data: requestData)
            return try JSONCustomDecoder().decode(Document.self, from: responseData)
        } catch {
            AnnotatoLogger.error("When updating document: \(String(describing: error))")
            return nil
        }
    }

    // MARK: DELETE
    func deleteDocument(document: Document) async -> Document? {
        do {
            let responseData =
                try await httpService.delete(url: "\(RemoteDocumentsPersistence.documentsUrl)/\(document.id)")
            return try JSONCustomDecoder().decode(Document.self, from: responseData)
        } catch {
            AnnotatoLogger.error("When deleting document: \(String(describing: error))")
            return nil
        }
    }

    func createOrUpdateDocument(document: Document) -> Document? {
        fatalError("RemoteDocumentsPersistence::createOrUpdateDocument: This function should not be called")
        return nil
    }

    func createOrUpdateDocuments(documents: [Document]) -> [Document]? {
        fatalError("RemoteDocumentsPersistence::createOrUpdateDocuments: This function should not be called")
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
