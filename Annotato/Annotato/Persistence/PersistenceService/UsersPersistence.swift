import AnnotatoSharedLibrary

protocol UsersPersistence {
    func createUser(user: AnnotatoUser) async -> AnnotatoUser?
}
