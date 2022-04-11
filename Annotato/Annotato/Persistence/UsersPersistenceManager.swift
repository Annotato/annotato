import AnnotatoSharedLibrary

class UsersPersistenceManager: UsersPersistence {
    private let remotePersistence = RemotePersistenceService()
    private let localPersistence = LocalPersistenceService.shared

    func createUser(user: AnnotatoUser) async -> AnnotatoUser? {
        guard let remoteUser = await remotePersistence.users.createUser(user: user) else {
            return nil
        }

        return remoteUser
    }

    func getUser(userId: String) async -> AnnotatoUser? {
        let remoteUser = await remotePersistence.users.getUser(userId: userId)

        if remoteUser == nil {
            return await localPersistence.users.getUser(userId: userId)
        }

        return remoteUser
    }
}
