import Vapor

func documentSharesRouter(documentShares: RoutesBuilder) {
    let documentSharesController = DocumentSharesController()

    documentShares.post(use: documentSharesController.create)

    documentShares.group(":documentId") { documentShare in
        documentShare.delete(":recipientId", use: documentSharesController.delete)
    }
}
