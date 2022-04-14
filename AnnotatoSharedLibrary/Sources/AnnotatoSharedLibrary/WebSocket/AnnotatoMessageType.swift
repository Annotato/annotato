/// Generic message types
public enum AnnotatoMessageType: String, Codable {
    case crudDocument, crudAnnotation
}

/// Subtypes of `AnnotatoCudDocumentMessage`
public enum AnnotatoCudDocumentMessageType: String, Codable {
    case createDocument
    case updateDocument
    case deleteDocument
}

/// Subtypes of `AnnotatoCudAnnotationMessage`
public enum AnnotatoCudAnnotationMessageType: String, Codable {
    case createAnnotation
    case updateAnnotation
    case deleteAnnotation
    case createOrUpdateAnnotation
}
