import Vapor

func documentsRouter(documents: RoutesBuilder) {
    documents.get(use: DocumentsController.list)

    documents.post(use: DocumentsController.create)

    documents.group(":id") { document in
        document.get(use: DocumentsController.read)

        document.put(use: DocumentsController.update)

        document.delete(use: DocumentsController.delete)
    }
}
