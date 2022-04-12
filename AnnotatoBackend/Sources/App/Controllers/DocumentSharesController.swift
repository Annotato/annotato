import Foundation
import Vapor
import AnnotatoSharedLibrary

struct DocumentSharesController {
    private let documentsDataAccess = DocumentsDataAccess()
    private let documentSharesDataAccess = DocumentSharesDataAccess()

    private enum QueryParams: String {
        case documentId
        case recipientId
    }

    func create(req: Request) async throws -> Document {
        let documentShare = try req.content.decode(DocumentShare.self, using: JSONCustomDecoder())

        _ = try await documentSharesDataAccess.create(db: req.db, documentShare: documentShare)
        return try await documentsDataAccess.read(db: req.db, documentId: documentShare.documentId)
    }

    func delete(req: Request) async throws -> Document {
        let documentId = try req.getParamValueAsUUID(paramKey: "documentId")
        let recipientId = try req.getParamValue(paramKey: "recipientId")

        _ = try await DocumentSharesDataAccess.delete(
            db: req.db, documentId: documentId, recipientId: recipientId)
        return try await documentsDataAccess.read(db: req.db, documentId: documentId)
    }
}
