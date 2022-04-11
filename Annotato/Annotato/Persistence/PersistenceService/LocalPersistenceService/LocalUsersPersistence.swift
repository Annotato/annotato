import AnnotatoSharedLibrary

struct LocalUsersPersistence: UsersPersistence {
    func createUser(user: AnnotatoUser) async -> AnnotatoUser? {
        fatalError("Should not create User in local persistence!")
        return nil
    }
}
