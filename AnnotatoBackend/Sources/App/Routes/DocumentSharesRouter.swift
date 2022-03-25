import Vapor

func documentSharesRouter(documentShares: RoutesBuilder) {
    documentShares.post(use: DocumentSharesController.create)
}
