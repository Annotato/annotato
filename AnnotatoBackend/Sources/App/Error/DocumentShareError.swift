import Foundation
import AnnotatoSharedLibrary

struct DocumentShareError: Error {
    enum ErrorType: String {
        case modelNotFound
        case sharingWithSelf
    }

    enum RequestType: String {
        case create
        case update
        case delete
    }

    let errorType: ErrorType
    let requestType: RequestType
    let description: String

    static func modelNotFound(
        requestType: RequestType,
        documentId: UUID,
        recipientId: String
    ) -> DocumentShareError {
        let modelType = String(describing: DocumentShareEntity.self)

        return DocumentShareError(
            errorType: .modelNotFound, requestType: requestType,
            description: "Could not \(requestType) \(modelType) - \(modelType) with document ID \(documentId) " +
            "and recipient ID \(recipientId) does not exist"
        )
    }

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
