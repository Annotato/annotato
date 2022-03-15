import Vapor

func documentsRouter(documents: RoutesBuilder) {
    documents.get(use: DocumentsController.list)

    documents.post(use: DocumentsController.create)

    documents.group(":id") { document in
        document.delete(use: DocumentsController.delete)
    }
}
