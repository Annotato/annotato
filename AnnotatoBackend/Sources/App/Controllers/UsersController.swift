import AnnotatoSharedLibrary
import Vapor
import Foundation

struct UsersController {
    private enum QueryParams: String {
        case documentId
    }

    static func create(req: Request) async throws -> User {
        let user = try req.content.decode(User.self, using: JSONCustomDecoder())

        return try await UsersDataAccess.create(db: req.db, user: user)
    }

    static func listUsersSharingDocument(req: Request) async throws -> [User] {
        let documentId: String? = req.query[QueryParams.documentId.rawValue]

        guard let documentId = UUID(uuidString: documentId ?? "") else {
            throw Abort(.badRequest)
        }

        return try await UsersDataAccess.listUsersSharingDocument(db: req.db, documentId: documentId)
    }
}
