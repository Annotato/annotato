import FluentKit
import AnnotatoSharedLibrary
import Foundation

struct UsersDataAccess {
    static func create(db: Database, user: User) async throws -> User {
        let userEntity = UserEntity.fromModel(user)

        try await db.transaction { tx in
            try await userEntity.customCreate(on: tx)
        }

        return User.fromManagedEntity(userEntity)
    }

    // Note: This excludes the document owner
    static func listUsersSharingDocument(db: Database, documentId: UUID) async throws -> [User] {
        let userEntities = try await UserEntity
            .query(on: db)
            .join(DocumentShareEntity.self, on: \UserEntity.$id == \DocumentShareEntity.$recipientEntity.$id)
            .filter(DocumentShareEntity.self, \DocumentShareEntity.$documentEntity.$id == documentId)
            .all().get()

        return userEntities.map(User.fromManagedEntity)
    }
}
