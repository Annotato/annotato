public final class AnnotatoMessage: Codable {
    public let type: AnnotatoMessageType

    public required init(type: AnnotatoMessageType) {
        self.type = type
    }
}

extension AnnotatoMessage: CustomDebugStringConvertible {
    public var debugDescription: String {
        "AnnotatoMessage(type: \(type))"
    }
}
