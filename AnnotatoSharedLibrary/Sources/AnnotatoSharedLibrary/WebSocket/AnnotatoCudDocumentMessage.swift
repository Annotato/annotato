public class AnnotatoCudDocumentMessage: Codable {
    public private(set) var type = AnnotatoMessageType.crudDocument
    public let senderId: String
    public let subtype: AnnotatoCudDocumentMessageType
    public let document: Document

    public required init(senderId: String, subtype: AnnotatoCudDocumentMessageType, document: Document) {
        self.senderId = senderId
        self.subtype = subtype
        self.document = document
    }
}

extension AnnotatoCudDocumentMessage: CustomDebugStringConvertible {
    public var debugDescription: String {
        "AnnotatoCudDocumentMessage(senderId: \(senderId), type: \(type), subtype: \(subtype), document: \(document))"
    }
}
