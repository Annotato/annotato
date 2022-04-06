public class AnnotatoCudDocumentMessage: Codable {
    public private(set) var type = AnnotatoMessageType.crudDocument
    public let subtype: AnnotatoCudDocumentMessageType
    public let document: Document

    public required init(subtype: AnnotatoCudDocumentMessageType, document: Document) {
        self.subtype = subtype
        self.document = document
    }
}

extension AnnotatoCudDocumentMessage: CustomDebugStringConvertible {
    public var debugDescription: String {
        "AnnotatoCudDocumentMessage(type: \(type), subtype: \(subtype), document: \(document))"
    }
}
