public final class AnnotatoAnnotationMessage: Codable, WebSocketMessage {
    public let type: WebSocketMessageType
    public var modelType = ModelType.annotation
    public let annotation: Annotation

    public required init(type: WebSocketMessageType, annotation: Annotation) {
        self.type = type
        self.annotation = annotation
    }
}

extension AnnotatoAnnotationMessage: CustomDebugStringConvertible {
    public var debugDescription: String {
        "AnnotatoAnnotationMessage(type: \(type), modelType: \(modelType), annotation: \(annotation))"
    }
}
