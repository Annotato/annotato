import Foundation

struct AnnotatoError: Error {
    enum ErrorType: String {
        case modelNotFound
        case modelAlreadyExists
    }

    enum RequestType: String {
        case create
        case read
        case update
        case delete
    }

    let errorType: ErrorType
    let requestType: RequestType
    let description: String

    static func modelNotFound(requestType: RequestType, modelType: String, modelId: UUID) -> AnnotatoError {
        AnnotatoError(
            errorType: .modelNotFound, requestType: requestType,
            description: "Could not \(requestType) \(modelType) - \(modelType) with ID \(modelId) does not exist"
        )
    }

    static func modelNotFound(requestType: RequestType, modelType: String, modelId: String) -> AnnotatoError {
        AnnotatoError(
            errorType: .modelNotFound, requestType: requestType,
            description: "Could not \(requestType) \(modelType) - \(modelType) with ID \(modelId) does not exist"
        )
    }

    static func modelAlreadyExists(
        modelType: String,
        modelId: UUID,
        requestType: RequestType = .create
    ) -> AnnotatoError {
        AnnotatoError(
            errorType: .modelAlreadyExists, requestType: requestType,
            description: "Could not \(requestType) \(modelType) - \(modelType) with ID \(modelId) already exists"
        )
    }
}
