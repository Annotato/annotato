import Foundation
import AnnotatoSharedLibrary

struct DocumentsAPI {
    private static let documentsUrl = "\(BaseAPI.baseAPIUrl)/documents"

    private var httpService: AnnotatoHTTPService

    init() {
        httpService = URLSessionHTTPService()
    }

    var delegate: AnnotatoHTTPDelegate? {
        get { httpService.delegate }
        set { httpService.delegate = newValue }
    }

    func getDocuments(userId: UUID) {
        httpService.get(url: DocumentsAPI.documentsUrl, params: ["userId": userId.uuidString])
    }

    func getDocument(documentId: UUID) {
        httpService.get(url: "\(DocumentsAPI.documentsUrl)/\(documentId)")
    }

    func createDocument(document: Document) {
        guard let data = encodeDocument(document) else {
            return
        }

        httpService.post(url: DocumentsAPI.documentsUrl, data: data)
    }

    func updateDocument(document: Document) {
        guard let data = encodeDocument(document) else {
            return
        }

        httpService.put(url: DocumentsAPI.documentsUrl, data: data)
    }

    func deleteDocument(documentId: UUID) {
        httpService.delete(url: "\(DocumentsAPI.documentsUrl)/\(documentId)")
    }

    private func encodeDocument(_ document: Document) -> Data? {
        do {
            let data = try JSONEncoder().encode(document)
            print(String(data: data, encoding: .utf8))
            return data
        } catch {
            AnnotatoLogger.error("Could not encode Document into JSON",
                                 context: "DocumentsAPI::encodeDocument")
            return nil
        }
    }
}

class DummyDelegate: AnnotatoHTTPDelegate {
    func requestDidFail(_ error: Error) {
        print("Request Failed")

        print(error)
    }

    func requestDidSucceed(data: Data?) {
        print("Request Succeeded")

        print(data)
    }
}
