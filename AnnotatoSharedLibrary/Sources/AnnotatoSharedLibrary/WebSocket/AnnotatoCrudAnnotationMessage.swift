public class AnnotatoCrudAnnotationMessage: Codable {
    public private(set) var type = AnnotatoMessageType.crudAnnotation
    public let subtype: AnnotatoCrudAnnotationMessageType
    public let annotation: Annotation

    public required init(subtype: AnnotatoCrudAnnotationMessageType, annotation: Annotation) {
        self.subtype = subtype
        self.annotation = annotation
    }
}

extension AnnotatoCrudAnnotationMessage: CustomDebugStringConvertible {
    public var debugDescription: String {
        "AnnotatoCrudDocumentMessage(type: \(type), subtype: \(subtype), annotation: \(annotation))"
    }
}
