import AnnotatoSharedLibrary

struct RemoteAnnotationsPersistence: AnnotationsPersistence {
    func createAnnotation(annotation: Annotation) async -> Annotation? {
        guard let senderId = AnnotatoAuth().currentUser?.uid else {
            return nil
        }

        let webSocketMessage = AnnotatoCudAnnotationMessage(
            senderId: senderId, subtype: .createAnnotation, annotation: annotation
        )

        WebSocketManager.shared.send(message: webSocketMessage)

        // We do not get any response for the sender from the websocket
        return nil
    }

    func updateAnnotation(annotation: Annotation) async -> Annotation? {
        guard let senderId = AnnotatoAuth().currentUser?.uid else {
            return nil
        }

        let webSocketMessage = AnnotatoCudAnnotationMessage(
            senderId: senderId, subtype: .updateAnnotation, annotation: annotation
        )

        WebSocketManager.shared.send(message: webSocketMessage)

        // We do not get any response for the sender from the websocket
        return nil
    }

    func deleteAnnotation(annotation: Annotation) async -> Annotation? {
        guard let senderId = AnnotatoAuth().currentUser?.uid else {
            return nil
        }

        let webSocketMessage = AnnotatoCudAnnotationMessage(
            senderId: senderId, subtype: .deleteAnnotation, annotation: annotation
        )

        WebSocketManager.shared.send(message: webSocketMessage)

        // We do not get any response for the sender from the websocket
        return nil
    }

    func createOrUpdateAnnotation(annotation: Annotation) async -> Annotation? {
        // TODO: Needs to be implemented, by sending a websocket message with new message type I made
        fatalError("RemoteAnnotationsPersistence::createOrUpdateAnnotation: This function should not be called")
        return nil
    }

    func createOrUpdateAnnotations(annotations: [Annotation]) async -> [Annotation]? {
        // TODO: Needs to be implemented, by sending a websocket message with new message type I made
        fatalError("RemoteAnnotationsPersistence::createOrUpdateAnnotations: This function should not be called")
        return nil
    }
}
