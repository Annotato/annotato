protocol WebSocketMessage: Codable {
    var type: WebSocketMessageType { get }
    var modelType: ModelType { get }
}
