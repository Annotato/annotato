import AnnotatoSharedLibrary

struct RemoteAnnotationsPersistence: AnnotationsPersistence {
    func createAnnotation(annotation: Annotation) async -> Annotation? {
        let webSocketMessage = AnnotatoCudAnnotationMessage(
            subtype: .createAnnotation, annotation: annotation
        )

        WebSocketManager.shared.send(message: webSocketMessage)

        // We do not get any response for the sender from the websocket
        return nil
    }

    func updateAnnotation(annotation: Annotation) async -> Annotation? {
        let webSocketMessage = AnnotatoCudAnnotationMessage(
            subtype: .updateAnnotation, annotation: annotation
        )

        WebSocketManager.shared.send(message: webSocketMessage)

        // We do not get any response for the sender from the websocket
        return nil
    }

    func deleteAnnotation(annotation: Annotation) async -> Annotation? {
        let webSocketMessage = AnnotatoCudAnnotationMessage(
            subtype: .deleteAnnotation, annotation: annotation
        )

        WebSocketManager.shared.send(message: webSocketMessage)

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
