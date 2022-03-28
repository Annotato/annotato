/// Generic message types
public enum AnnotatoMessageType: String, Codable {
    case crudDocument, crudAnnotation, offlineToOnline
}

/// Subtypes of `AnnotatoCrudDocumentMessage`
public enum AnnotatoCrudDocumentMessageType: String, Codable {
    case createDocument
    case readDocument
    case updateDocument
    case deleteDocument
}

/// Subtypes of `AnnotatoCrudAnnotationMessage`
public enum AnnotatoCrudAnnotationMessageType: String, Codable {
    case createAnnotation
    case readAnnotation
    case updateAnnotation
    case deleteAnnotation
}

/// Merge Strategies of `AnnotatoOfflineToOnlineMessage`
public enum AnnotatoOfflineToOnlineMergeStrategy: String, Codable {
    case duplicateConflicts
    case overrideServerVersion
    case keepServerVersion
}
