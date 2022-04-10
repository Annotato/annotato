import Vapor

func documentSharesRouter(documentShares: RoutesBuilder) {
    let documentSharesController = DocumentSharesController()

    documentShares.post(use: documentSharesController.create)
}
