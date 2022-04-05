import AnnotatoSharedLibrary

struct RemoteAnnotationsPersistence: AnnotationsPersistence {
    func createAnnotation(annotation: Annotation) async -> Annotation? {
        let webSocketMessage = AnnotatoCrudAnnotationMessage(
            subtype: .createAnnotation, annotation: annotation
        )

        WebSocketManager.shared.send(message: webSocketMessage)

        // We do not get any reponse for the sender from the websocket
        return nil
    }

    func updateAnnotation(annotation: Annotation) async -> Annotation? {
        let webSocketMessage = AnnotatoCrudAnnotationMessage(
            subtype: .updateAnnotation, annotation: annotation
        )

        WebSocketManager.shared.send(message: webSocketMessage)

        // We do not get any reponse for the sender from the websocket
        return nil
    }

    func deleteAnnotation(annotation: Annotation) async -> Annotation? {
        let webSocketMessage = AnnotatoCrudAnnotationMessage(
            subtype: .deleteAnnotation, annotation: annotation
        )

        WebSocketManager.shared.send(message: webSocketMessage)

        // We do not get any reponse for the sender from the websocket
        return nil
    }

    func createOrUpdateAnnotationForLocal(annotation: Annotation) async -> Annotation? {
        AnnotatoLogger.error("This function should not be called",
                             context: "RemoteAnnotationsPersistence::createOrUpdateAnnotationForLocal")
        return nil
    }
}
