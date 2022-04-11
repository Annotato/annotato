import AnnotatoSharedLibrary
import Foundation

struct LocalUsersPersistence: UsersPersistence {
    func createUser(user: AnnotatoUser) async -> AnnotatoUser? {
        fatalError("Should not create User in local persistence!")
        return nil
    }

    func getUser(userId: String) async -> AnnotatoUser? {
        fatalError("Should not get User from local persistence!")
        return nil
    }
}
