public final class AnnotatoWebSocketMessage: Codable, WebSocketMessage {
    public let type: WebSocketMessageType
    public let modelType: ModelType

    public required init(type: WebSocketMessageType, modelType: ModelType) {
        self.type = type
        self.modelType = modelType
    }
}

extension AnnotatoWebSocketMessage: CustomDebugStringConvertible {
    public var debugDescription: String {
        "AnnotatoWebSocketMessage(type: \(type))"
    }
}
