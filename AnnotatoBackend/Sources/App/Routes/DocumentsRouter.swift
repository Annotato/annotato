import Vapor

func documentsRouter(documents: RoutesBuilder) {
    documents.get(use: DocumentsController.listOwn)

    documents.get("shared", use: DocumentsController.listShared)

    documents.post(use: DocumentsController.create)

    documents.group(":id") { document in
        document.get(use: DocumentsController.read)

        document.put(use: DocumentsController.update)

        document.delete(use: DocumentsController.delete)

        let webSocketController = DocumentsWebSocketController()
        document.webSocket("edit", onUpgrade: webSocketController.handleIncomingConnection)
    }
}
