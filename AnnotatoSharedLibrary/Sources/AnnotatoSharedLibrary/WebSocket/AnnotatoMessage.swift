public final class AnnotatoMessage: Codable {
    public let type: AnnotatoMessageType
    public let senderId: String

    public required init(type: AnnotatoMessageType, senderId: String) {
        self.type = type
        self.senderId = senderId
    }
}

extension AnnotatoMessage: CustomDebugStringConvertible {
    public var debugDescription: String {
        "AnnotatoMessage(type: \(type), senderId: \(senderId))"
    }
}
