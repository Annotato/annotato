import AnnotatoSharedLibrary

protocol AnnotationsRemotePersistence {
    func createAnnotation(annotation: Annotation, webSocketManager: WebSocketManager?) async -> Annotation?
    func updateAnnotation(annotation: Annotation, webSocketManager: WebSocketManager?) async -> Annotation?
    func deleteAnnotation(annotation: Annotation, webSocketManager: WebSocketManager?) async -> Annotation?
    func createOrUpdateAnnotation(annotation: Annotation) async -> Annotation?
    func createOrUpdateAnnotations(annotations: [Annotation]) async -> [Annotation]?
}
