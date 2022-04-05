import AnnotatoSharedLibrary

struct RemoteAnnotationsPersistence: AnnotationsPersistence {
    func createAnnotation(annotation: Annotation) async -> Annotation? {
        let webSocketMessage = AnnotatoCrudAnnotationMessage(
            subtype: .createAnnotation, annotation: annotation
        )

        WebSocketManager.shared.send(message: webSocketMessage)

        // We do not get any response for the sender from the websocket
        return nil
    }

    func updateAnnotation(annotation: Annotation) async -> Annotation? {
        let webSocketMessage = AnnotatoCrudAnnotationMessage(
            subtype: .updateAnnotation, annotation: annotation
        )

        WebSocketManager.shared.send(message: webSocketMessage)

        // We do not get any response for the sender from the websocket
        return nil
    }

    func deleteAnnotation(annotation: Annotation) async -> Annotation? {
        let webSocketMessage = AnnotatoCrudAnnotationMessage(
            subtype: .deleteAnnotation, annotation: annotation
        )

        WebSocketManager.shared.send(message: webSocketMessage)

        // We do not get any response for the sender from the websocket
        return nil
    }

    func createOrUpdateAnnotationsForLocal(annotations: [Annotation]) -> [Annotation]? {
        fatalError("RemoteAnnotationsPersistence::createOrUpdateAnnotationForLocal: This function should not be called")
        return nil
    }
}
