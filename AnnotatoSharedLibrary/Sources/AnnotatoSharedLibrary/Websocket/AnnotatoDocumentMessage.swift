public final class AnnotatoDocumentMessage: Codable {
    public let type: WebSocketMessageType
    public var modelType = ModelType.document
    public let document: Document

    public required init(type: WebSocketMessageType, document: Document) {
        self.type = type
        self.document = document
    }
}

extension AnnotatoDocumentMessage: CustomDebugStringConvertible {
    public var debugDescription: String {
        "AnnotatoDocumentMessage(type: \(type), modelType: \(modelType), document: \(document))"
    }
}
