import Foundation
import Vapor
import AnnotatoSharedLibrary

struct DocumentsController {
    private enum QueryParams: String {
        case userId
    }

    static func list(req: Request) throws -> EventLoopFuture<[Document]> {
        let userId: UUID? = req.query[QueryParams.userId.rawValue]

        guard let userId = userId else {
            throw Abort(.badRequest)
        }

        return DocumentsDataAccess.list(db: req.db, userId: userId)
    }

    static func create(req: Request) throws -> EventLoopFuture<Document> {
        let document = try req.content.decode(Document.self)

        return DocumentsDataAccess.create(db: req.db, document: document)
    }

    static func read(req: Request) throws -> EventLoopFuture<Document> {
        let documentId = try ControllersUtil.getIdFromParams(request: req)

        return DocumentsDataAccess.read(db: req.db, documentId: documentId)
    }

    static func update(req: Request) throws -> EventLoopFuture<Document> {
        let document = try req.content.decode(Document.self)

        return DocumentsDataAccess.update(db: req.db, document: document)
    }

    static func delete(req: Request) throws -> EventLoopFuture<Document> {
        let documentId = try ControllersUtil.getIdFromParams(request: req)

        return DocumentsDataAccess.delete(db: req.db, documentId: documentId)
    }
}
