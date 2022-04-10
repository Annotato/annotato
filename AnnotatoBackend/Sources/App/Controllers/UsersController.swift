import AnnotatoSharedLibrary
import Vapor

struct UsersController {
    private enum QueryParams: String {
        case userId
    }

    static func create(req: Request) async throws -> User {
        let user = try req.content.decode(User.self, using: JSONCustomDecoder())

        return try await UsersDataAccess.create(db: req.db, user: user)
    }
}
