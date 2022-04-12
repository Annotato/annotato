import Foundation
import Vapor
import AnnotatoSharedLibrary

struct DocumentsController {
    private let documentsDataAccess = DocumentsDataAccess()
    private let documentSharesDataAccess = DocumentSharesDataAccess()

    private enum QueryParams: String {
        case userId
    }

    func listOwn(req: Request) async throws -> [Document] {
        let userId: String? = req.query[QueryParams.userId.rawValue]

        guard let userId = userId else {
            throw Abort(.badRequest)
        }

        return try await documentsDataAccess.listOwn(db: req.db, userId: userId)
    }

    func listShared(req: Request) async throws -> [Document] {
        let userId: String? = req.query[QueryParams.userId.rawValue]

        guard let userId = userId else {
            throw Abort(.badRequest)
        }

        return try await documentsDataAccess.listShared(db: req.db, userId: userId)
    }

    func create(req: Request) async throws -> Document {
        let document = try req.content.decode(Document.self, using: JSONCustomDecoder())

        return try await documentsDataAccess.create(db: req.db, document: document)
    }

    func read(req: Request) async throws -> Document {
        let documentId = try req.getIdValueAsUUID()

        return try await documentsDataAccess.read(db: req.db, documentId: documentId)
    }

    func update(req: Request) async throws -> Document {
        let documentId = try req.getIdValueAsUUID()
        let document = try req.content.decode(Document.self, using: JSONCustomDecoder())

        return try await documentsDataAccess.update(db: req.db, documentId: documentId, document: document)
    }

    func delete(req: Request) async throws -> Document {
        let documentId = try req.getIdValueAsUUID()

        let deletedDocument = try await documentsDataAccess.delete(db: req.db, documentId: documentId)
        _ = try await documentSharesDataAccess.delete(db: req.db, documentId: deletedDocument.id)

        return deletedDocument
    }
}
