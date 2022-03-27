public final class AnnotatoWebSocketMessage: Codable {
    public let type: WebSocketMessageType
    public let modelType: ModelType

    public required init(type: WebSocketMessageType, modelType: ModelType) {
        self.type = type
        self.modelType = modelType
    }
}

public enum WebSocketMessageType: String, Codable {
    case create
    case read
    case update
    case delete
}

extension AnnotatoWebSocketMessage: CustomDebugStringConvertible {
    public var debugDescription: String {
        "AnnotatoWebSocketMessage(type: \(type))"
    }
}
