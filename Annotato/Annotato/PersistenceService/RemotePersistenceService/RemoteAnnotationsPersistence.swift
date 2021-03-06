import AnnotatoSharedLibrary

struct RemoteAnnotationsPersistence {
    private let webSocketManager: WebSocketManager?

    init(webSocketManager: WebSocketManager?) {
        self.webSocketManager = webSocketManager
    }

    func createAnnotation(annotation: Annotation, senderId: String) async -> Annotation? {
        let webSocketMessage = AnnotatoCudAnnotationMessage(
            senderId: senderId, subtype: .createAnnotation, annotation: annotation
        )

        webSocketManager?.send(message: webSocketMessage)

        return nil
    }

    func updateAnnotation(annotation: Annotation, senderId: String) async -> Annotation? {
        let webSocketMessage = AnnotatoCudAnnotationMessage(
            senderId: senderId, subtype: .updateAnnotation, annotation: annotation
        )

        webSocketManager?.send(message: webSocketMessage)

        return nil
    }

    func deleteAnnotation(annotation: Annotation, senderId: String) async -> Annotation? {
        let webSocketMessage = AnnotatoCudAnnotationMessage(
            senderId: senderId, subtype: .deleteAnnotation, annotation: annotation
        )

        webSocketManager?.send(message: webSocketMessage)

        return nil
    }

    func createOrUpdateAnnotation(annotation: Annotation, senderId: String) async -> Annotation? {
        let webSocketMessage = AnnotatoCudAnnotationMessage(
            senderId: senderId,
            subtype: .createOrUpdateAnnotation,
            annotation: annotation
        )
        webSocketManager?.send(message: webSocketMessage)

        return nil
    }
}
