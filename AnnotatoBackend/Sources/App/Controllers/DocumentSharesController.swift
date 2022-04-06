import Foundation
import Vapor
import AnnotatoSharedLibrary

struct DocumentSharesController {
    static func create(req: Request) async throws -> Document {
        let documentShare = try req.content.decode(DocumentShare.self, using: JSONCustomDecoder())

        _ = try await DocumentSharesDataAccess.create(db: req.db, documentShare: documentShare)
        return try await DocumentsDataAccess.read(db: req.db, documentId: documentShare.documentId)
    }
}
