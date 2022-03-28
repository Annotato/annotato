public class AnnotatoCrudDocumentMessage: Codable {
    public var type = AnnotatoMessageType.crudDocument
    public let subtype: AnnotatoCrudDocumentMessageType
    public let document: Document

    public required init(subtype: AnnotatoCrudDocumentMessageType, document: Document) {
        self.subtype = subtype
        self.document = document
    }
}

extension AnnotatoCrudDocumentMessage: CustomDebugStringConvertible {
    public var debugDescription: String {
        "AnnotatoCrudDocumentMessage(type: \(type), subtype: \(subtype), document: \(document))"
    }
}
