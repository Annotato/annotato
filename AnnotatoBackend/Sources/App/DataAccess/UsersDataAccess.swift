import FluentKit
import AnnotatoSharedLibrary

struct UsersDataAccess {
    static func create(db: Database, user: User) async throws -> User {
        let userEntity = UserEntity.fromModel(user)

        try await db.transaction { tx in
            try await userEntity.customCreate(on: tx)
        }

        return User.fromManagedEntity(userEntity)
    }
}
