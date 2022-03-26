import Foundation
import Vapor
import AnnotatoSharedLibrary

struct DocumentsController {
    private enum QueryParams: String {
        case userId
    }

    static func list(req: Request) async throws -> [Document] {
        let userId: String? = req.query[QueryParams.userId.rawValue]

        guard let userId = userId else {
            throw Abort(.badRequest)
        }

        return try await DocumentsDataAccess.listAll(db: req.db, userId: userId)
    }

    static func listShared(req: Request) async throws -> [Document] {
        let userId: String? = req.query[QueryParams.userId.rawValue]

        guard let userId = userId else {
            throw Abort(.badRequest)
        }

        return try await DocumentsDataAccess.listShared(db: req.db, userId: userId)
    }

    static func create(req: Request) async throws -> Document {
        let document = try req.content.decode(Document.self)

        return try await DocumentsDataAccess.create(db: req.db, document: document)
    }

    static func read(req: Request) async throws -> Document {
        let documentId = try ControllersUtil.getIdFromParams(request: req)

        return try await DocumentsDataAccess.read(db: req.db, documentId: documentId)
    }

    static func update(req: Request) async throws -> Document {
        let documentId = try ControllersUtil.getIdFromParams(request: req)
        let document = try req.content.decode(Document.self)

        return try await DocumentsDataAccess.update(db: req.db, documentId: documentId, document: document)
    }

    static func delete(req: Request) async throws -> Document {
        let documentId = try ControllersUtil.getIdFromParams(request: req)

        return try await DocumentsDataAccess.delete(db: req.db, documentId: documentId)
    }
}
