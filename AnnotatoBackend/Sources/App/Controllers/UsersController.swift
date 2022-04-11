import AnnotatoSharedLibrary
import Vapor
import Foundation

struct UsersController {
    private let usersDataAccess = UsersDataAccess()

    private enum QueryParams: String {
        case documentId
    }

    func create(req: Request) async throws -> AnnotatoUser {
        let user = try req.content.decode(AnnotatoUser.self, using: JSONCustomDecoder())

        return try await usersDataAccess.create(db: req.db, user: user)
    }

    func listUsersSharingDocument(req: Request) async throws -> [AnnotatoUser] {
        let documentId: String? = req.query[QueryParams.documentId.rawValue]

        guard let documentId = UUID(uuidString: documentId ?? "") else {
            throw Abort(.badRequest)
        }

        return try await usersDataAccess.listUsersSharingDocument(db: req.db, documentId: documentId)
    }
}
