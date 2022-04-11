import AnnotatoSharedLibrary

struct RemoteAnnotationsPersistence: AnnotationsRemotePersistence {
    func createAnnotation(annotation: Annotation, webSocketManager: WebSocketManager?) async -> Annotation? {
        guard let senderId = AuthViewModel().currentUser?.uid else {
            return nil
        }

        let webSocketMessage = AnnotatoCudAnnotationMessage(
            senderId: senderId, subtype: .createAnnotation, annotation: annotation
        )

        webSocketManager?.send(message: webSocketMessage)

        // We do not get any response for the sender from the websocket
        return nil
    }

    func updateAnnotation(annotation: Annotation, webSocketManager: WebSocketManager?) async -> Annotation? {
        guard let senderId = AuthViewModel().currentUser?.uid else {
            return nil
        }

        let webSocketMessage = AnnotatoCudAnnotationMessage(
            senderId: senderId, subtype: .updateAnnotation, annotation: annotation
        )

        webSocketManager?.send(message: webSocketMessage)

        // We do not get any response for the sender from the websocket
        return nil
    }

    func deleteAnnotation(annotation: Annotation, webSocketManager: WebSocketManager?) async -> Annotation? {
        guard let senderId = AuthViewModel().currentUser?.uid else {
            return nil
        }

        let webSocketMessage = AnnotatoCudAnnotationMessage(
            senderId: senderId, subtype: .deleteAnnotation, annotation: annotation
        )

        webSocketManager?.send(message: webSocketMessage)

        // We do not get any response for the sender from the websocket
        return nil
    }

    func createOrUpdateAnnotation(annotation: Annotation) -> Annotation? {
        fatalError("RemoteAnnotationsPersistence::createOrUpdateAnnotation: This function should not be called")
        return nil
    }

    func createOrUpdateAnnotations(annotations: [Annotation]) -> [Annotation]? {
        fatalError("RemoteAnnotationsPersistence::createOrUpdateAnnotations: This function should not be called")
        return nil
    }
}
