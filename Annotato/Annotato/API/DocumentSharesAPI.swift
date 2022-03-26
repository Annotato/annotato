import AnnotatoSharedLibrary
import Foundation

struct DocumentSharesAPI {
    private static let documentSharesUrl = "\(BaseAPI.baseAPIUrl)/documentShares"

    private var httpService: AnnotatoHTTPService

    init() {
        httpService = URLSessionHTTPService()
    }

    // MARK: CREATE
    func createDocumentShare(documentShare: DocumentShare) async -> DocumentShare? {
        guard let requestData = encodeDocumentShare(documentShare) else {
            AnnotatoLogger.error("DocumentShare was not created",
                                 context: "DocumentSharesAPI::createDocumentShare")
            return nil
        }

        do {
            let responseData = try await httpService.post(url: DocumentSharesAPI.documentSharesUrl, data: requestData)
            return try JSONDecoder().decode(DocumentShare.self, from: responseData)
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
                                 context: "DocumentSharesAPI::encodeDocumentShare")
            return nil
        }
    }
}
