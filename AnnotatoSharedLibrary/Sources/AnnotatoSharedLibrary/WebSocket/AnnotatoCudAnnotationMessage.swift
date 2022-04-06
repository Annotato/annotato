public class AnnotatoCudAnnotationMessage: Codable {
    public private(set) var type = AnnotatoMessageType.crudAnnotation
    public let subtype: AnnotatoCudAnnotationMessageType
    public let annotation: Annotation

    public required init(subtype: AnnotatoCudAnnotationMessageType, annotation: Annotation) {
        self.subtype = subtype
        self.annotation = annotation
    }
}

extension AnnotatoCudAnnotationMessage: CustomDebugStringConvertible {
    public var debugDescription: String {
        "AnnotatoCudAnnotationMessage(type: \(type), subtype: \(subtype), annotation: \(annotation))"
    }
}
