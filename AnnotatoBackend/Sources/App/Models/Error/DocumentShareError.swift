import Foundation
import AnnotatoSharedLibrary

struct DocumentShareError: Error {
    enum ErrorType: String {
        case sharingWithSelf
    }

    enum RequestType: String {
        case create
        case update
    }

    let errorType: ErrorType
    let requestType: RequestType
    let description: String

    static func sharingWithSelf(
        documentShare: DocumentShare,
        requestType: RequestType
    ) -> DocumentShareError {
        let modelType = String(describing: DocumentShareEntity.self)

        return DocumentShareError(
            errorType: .sharingWithSelf, requestType: requestType,
            description: "Could not \(requestType) \(modelType) - \(modelType) with document ID " +
            "\(documentShare.documentId) already belongs to recipient with ID \(documentShare.recipientId)"
        )
    }
}
