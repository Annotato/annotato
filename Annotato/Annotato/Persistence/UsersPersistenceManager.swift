import AnnotatoSharedLibrary
import Foundation

class UsersPersistenceManager: UsersRemotePersistence {
    private let remotePersistence = RemotePersistenceService()
    private let savedUserKey = "savedUser"

    func createUser(user: AnnotatoUser) async -> AnnotatoUser? {
        guard let remoteUser = await remotePersistence.users.createUser(user: user) else {
            return nil
        }

        return remoteUser
    }

    func getUser(userId: String) async -> AnnotatoUser? {
        let remoteUser = await remotePersistence.users.getUser(userId: userId)

        return remoteUser
    }

    func saveSessionUser(user: AnnotatoUser) {
        guard let encodedUser = try? JSONCustomEncoder().encode(user) else {
            return
        }

        UserDefaults.standard.set(encodedUser, forKey: savedUserKey)
    }

    func fetchSessionUser() -> AnnotatoUser? {
        guard let savedUser = UserDefaults.standard.object(forKey: savedUserKey) as? Data,
              let decodedUser = try? JSONCustomDecoder().decode(AnnotatoUser.self, from: savedUser) else {
            return nil
        }

        return decodedUser
    }

    func purgeSessionUser() {
        UserDefaults.standard.removeObject(forKey: savedUserKey)
    }
}
