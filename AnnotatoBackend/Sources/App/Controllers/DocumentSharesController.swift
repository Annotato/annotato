import Foundation
import Vapor
import AnnotatoSharedLibrary

struct DocumentSharesController {
    private let documentsDataAccess = DocumentsDataAccess()
    private let documentSharesDataAccess = DocumentSharesDataAccess()

    func create(req: Request) async throws -> Document {
        let documentShare = try req.content.decode(DocumentShare.self, using: JSONCustomDecoder())

        _ = try await documentSharesDataAccess.create(db: req.db, documentShare: documentShare)
        return try await documentsDataAccess.read(db: req.db, documentId: documentShare.documentId)
    }
}
