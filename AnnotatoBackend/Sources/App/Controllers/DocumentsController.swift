import Foundation
import Vapor
import AnnotatoSharedLibrary

struct DocumentsController {
    static func list(req: Request) throws -> EventLoopFuture<[Document]> {
        let userId: UUID? = req.query["userId"]

        guard let userId = userId else {
            throw Abort(.badRequest)
        }

        return DocumentsDataAccess.list(db: req.db, userId: userId)
    }

    static func create(req: Request) throws -> EventLoopFuture<Document> {
        let document = try req.content.decode(Document.self)

        return DocumentsDataAccess.create(db: req.db, document: document)
    }

    static func delete(req: Request) throws -> HTTPResponseStatus {
        guard let param = req.parameters.get("id") else {
            req.application.logger.error("Failed to get expected param: id")
            throw Abort(.internalServerError)
        }

        guard let documentId = UUID(uuidString: param) else {
            req.application.logger.notice("Could not initialise UUID from param")
            throw Abort(.badRequest)
        }

        DocumentsDataAccess.delete(db: req.db, documentId: documentId)

        return .ok
    }
}
