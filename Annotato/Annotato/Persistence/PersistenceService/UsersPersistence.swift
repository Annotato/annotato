import AnnotatoSharedLibrary

protocol UsersPersistence {
    func createUser(user: AnnotatoUser) async -> AnnotatoUser?
    func getUser(userId: String) async -> AnnotatoUser?
}
