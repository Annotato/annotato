import Vapor

func documentsRouter(documents: RoutesBuilder) {
    let documentController = DocumentsController()

    documents.get(use: documentController.listOwn)

    documents.get("shared", use: documentController.listShared)

    documents.post(use: documentController.create)

    documents.group(":id") { document in
        document.get(use: documentController.read)

        document.put(use: documentController.update)

        document.delete(use: documentController.delete)
    }
}
