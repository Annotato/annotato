import AnnotatoSharedLibrary

struct RemoteAnnotationsPersistence {
    private let webSocketManager: WebSocketManager?

    init(webSocketManager: WebSocketManager?) {
        self.webSocketManager = webSocketManager
    }

    func createAnnotation(annotation: Annotation) async -> Annotation? {
        guard let senderId = AuthViewModel().currentUser?.id else {
            return nil
        }

        let webSocketMessage = AnnotatoCudAnnotationMessage(
            senderId: senderId, subtype: .createAnnotation, annotation: annotation
        )

        webSocketManager?.send(message: webSocketMessage)

        return nil
    }

    func updateAnnotation(annotation: Annotation) async -> Annotation? {
        guard let senderId = AuthViewModel().currentUser?.id else {
            return nil
        }

        let webSocketMessage = AnnotatoCudAnnotationMessage(
            senderId: senderId, subtype: .updateAnnotation, annotation: annotation
        )

        webSocketManager?.send(message: webSocketMessage)

        return nil
    }

    func deleteAnnotation(annotation: Annotation) async -> Annotation? {
        guard let senderId = AuthViewModel().currentUser?.id else {
            return nil
        }

        let webSocketMessage = AnnotatoCudAnnotationMessage(
            senderId: senderId, subtype: .deleteAnnotation, annotation: annotation
        )

        webSocketManager?.send(message: webSocketMessage)

        return nil
    }

    func createOrUpdateAnnotation(annotation: Annotation) async -> Annotation? {
        guard let senderId = AuthViewModel().currentUser?.id else {
            return nil
        }

        let webSocketMessage = AnnotatoCudAnnotationMessage(
            senderId: senderId,
            subtype: .createOrUpdateAnnotation,
            annotation: annotation
        )
        webSocketManager?.send(message: webSocketMessage)

        return nil
    }
}
