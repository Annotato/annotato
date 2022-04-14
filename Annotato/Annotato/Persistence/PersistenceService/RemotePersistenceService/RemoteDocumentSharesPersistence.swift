import AnnotatoSharedLibrary
import Foundation

struct RemoteDocumentSharesPersistence {
    private static let documentSharesUrl = "\(RemotePersistenceService.baseAPIUrl)/documentShares"

    private var httpService: AnnotatoHTTPService

    init() {
        httpService = URLSessionHTTPService()
    }

    // MARK: CREATE
    func createDocumentShare(documentShare: DocumentShare) async -> Document? {
        guard let requestData = encodeDocumentShare(documentShare) else {
            AnnotatoLogger.error("DocumentShare was not created",
                                 context: "RemoteDocumentSharesPersistence::createDocumentShare")
            return nil
        }

        do {
            let responseData =
                try await httpService.post(url: RemoteDocumentSharesPersistence.documentSharesUrl, data: requestData)
            return try JSONCustomDecoder().decode(Document.self, from: responseData)
        } catch {
            AnnotatoLogger.error("When creating document share: \(error.localizedDescription)")
            return nil
        }
    }

    // MARK: DELETE
    func deleteDocumentShare(documentId: UUID, recipientId: String) async -> Document? {
        do {
            let responseData = try await httpService.delete(
                url: "\(RemoteDocumentSharesPersistence.documentSharesUrl)/\(documentId.uuidString)/\(recipientId)")
            return try JSONCustomDecoder().decode(Document.self, from: responseData)
        } catch {
            AnnotatoLogger.error("When deleting document share: \(error.localizedDescription)")
            return nil
        }
    }

    // MARK: DELETE MANY
    func deleteDocumentShares(documentIds: [UUID], recipientId: String) async -> [Document]? {
        var documents: [Document] = []

        for documentId in documentIds {
            if let document = await deleteDocumentShare(documentId: documentId, recipientId: recipientId) {
                documents.append(document)
            }
        }

        return documents
    }

    private func encodeDocumentShare(_ documentShare: DocumentShare) -> Data? {
        do {
            let data = try JSONCustomEncoder().encode(documentShare)
            return data
        } catch {
            AnnotatoLogger.error("Could not encode DocumentShare into JSON. \(error.localizedDescription)",
                                 context: "RemoteDocumentSharesPersistence::encodeDocumentShare")
            return nil
        }
    }
}
