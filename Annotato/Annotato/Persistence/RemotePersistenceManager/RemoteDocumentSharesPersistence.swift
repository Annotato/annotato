import AnnotatoSharedLibrary
import Foundation

struct RemoteDocumentSharesPersistence: DocumentSharesPersistence {
    private static let documentSharesUrl = "\(RemotePersistenceManager.baseAPIUrl)/documentShares"

    private var httpService: AnnotatoHTTPService

    init() {
        httpService = URLSessionHTTPService()
    }

    // MARK: CREATE
    func createDocumentShare(documentShare: DocumentShare) async -> DocumentShare? {
        guard let requestData = encodeDocumentShare(documentShare) else {
            AnnotatoLogger.error("DocumentShare was not created",
                                 context: "RemoteDocumentSharesPersistence::createDocumentShare")
            return nil
        }

        do {
            let responseData =
                try await httpService.post(url: RemoteDocumentSharesPersistence.documentSharesUrl, data: requestData)
            return try JSONDateDecoder().decode(DocumentShare.self, from: responseData)
        } catch {
            AnnotatoLogger.error("When creating document share: \(error.localizedDescription)")
            return nil
        }
    }

    private func encodeDocumentShare(_ documentShare: DocumentShare) -> Data? {
        do {
            let data = try JSONEncoder().encode(documentShare)
            return data
        } catch {
            AnnotatoLogger.error("Could not encode DocumentShare into JSON. \(error.localizedDescription)",
                                 context: "RemoteDocumentSharesPersistence::encodeDocumentShare")
            return nil
        }
    }
}
