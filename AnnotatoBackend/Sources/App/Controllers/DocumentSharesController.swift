import Foundation
import Vapor
import AnnotatoSharedLibrary

struct DocumentSharesController {
    static func create(req: Request) async throws -> DocumentShare {
        let documentShare = try req.content.decode(DocumentShare.self, using: JSONCustomDecoder())

        return try await DocumentSharesDataAccess.create(db: req.db, documentShare: documentShare)
    }
}
