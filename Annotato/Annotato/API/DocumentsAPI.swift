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
}

class DocumentsHTTPDelegate: AnnotatoHTTPDelegate {
    func requestDidFail(_ error: Error) {
        print("Request Failed")

        print(error)
    }

    func requestDidSucceed(data: Data?) {
        print("Request Succeeded")

        print(data)
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
