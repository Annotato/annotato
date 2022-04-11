import AnnotatoSharedLibrary

protocol UsersRemotePersistence {
    func createUser(user: AnnotatoUser) async -> AnnotatoUser?
    func getUser(userId: String) async -> AnnotatoUser?
}
