import AnnotatoSharedLibrary
import Foundation

protocol AnnotatoAuthService {
    var delegate: AnnotatoAuthDelegate? { get set }
    var currentUser: AnnotatoUser? { get }
    func signUp(email: String, password: String, displayName: String)
    func logIn(email: String, password: String)
    func logOut()
}

extension AnnotatoAuthService {
    private var savedUserKey: String {
        "savedUser"
    }

    func storeCredentialsLocally() {
        guard let currentUser = currentUser,
              let encodedUser = try? JSONEncoder().encode(currentUser) else {
            return
        }

        UserDefaults.standard.set(encodedUser, forKey: savedUserKey)
    }

    func fetchLocalCredentials() -> AnnotatoUser? {
        guard let savedUser = UserDefaults.standard.object(forKey: savedUserKey) as? Data,
              let decodedUser = try? JSONDecoder().decode(AnnotatoUser.self, from: savedUser) else {
            return nil
        }

        return decodedUser
    }

    func purgeLocalCredentials() {
        UserDefaults.standard.removeObject(forKey: savedUserKey)
    }
}
