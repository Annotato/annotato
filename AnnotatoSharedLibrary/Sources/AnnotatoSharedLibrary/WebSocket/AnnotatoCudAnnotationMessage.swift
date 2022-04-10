public final class AnnotatoCudAnnotationMessage: Codable {
    public private(set) var type = AnnotatoMessageType.crudAnnotation
    public let senderId: String
    public let subtype: AnnotatoCudAnnotationMessageType
    public let annotation: Annotation

    public required init(senderId: String, subtype: AnnotatoCudAnnotationMessageType, annotation: Annotation) {
        self.senderId = senderId
        self.subtype = subtype
        self.annotation = annotation
    }
}

extension AnnotatoCudAnnotationMessage: CustomDebugStringConvertible {
    public var debugDescription: String {
        "AnnotatoCudAnnotationMessage(senderId: \(senderId), type: \(type), " +
        "subtype: \(subtype), annotation: \(annotation))"
    }
}
