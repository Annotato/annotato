import AnnotatoSharedLibrary
import Foundation

struct LocalUsersPersistence: UsersPersistence {
    let savedUserKey = "savedUser"

    func createUser(user: AnnotatoUser) async -> AnnotatoUser? {
        fatalError("Should not create User in local persistence!")
        return nil
    }

    func getUser(userId: String) async -> AnnotatoUser? {
        guard let savedUser = UserDefaults.standard.object(forKey: savedUserKey) as? Data,
              let decodedUser = try? JSONCustomDecoder().decode(AnnotatoUser.self, from: savedUser) else {
            return nil
        }

        return decodedUser
    }
}
