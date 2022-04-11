import AnnotatoSharedLibrary

class UsersPersistenceManager: UsersPersistence {
    private let remotePersistence = RemotePersistenceService()

    func createUser(user: AnnotatoUser) async -> AnnotatoUser? {
        guard let remoteUser = await remotePersistence.users.createUser(user: user) else {
            return nil
        }

        return remoteUser
    }
}
