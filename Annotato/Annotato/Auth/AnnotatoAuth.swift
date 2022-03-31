import AnnotatoSharedLibrary
import Foundation

class AnnotatoAuth {
    private var authService: AnnotatoAuthService

    init() {
        authService = FirebaseAuth()
    }

    var currentUser: AnnotatoUser? {
        fetchLocalUserCredentials() ?? authService.currentUser
    }

    var delegate: AnnotatoAuthDelegate? {
        get { authService.delegate }
        set { authService.delegate = newValue }
    }

    func signUp(email: String, password: String, displayName: String) {
        authService.signUp(email: email, password: password, displayName: displayName)
    }

    func logIn(email: String, password: String) {
        authService.logIn(email: email, password: password)

        storeCredentialsLocally()
    }

    func logOut() {
        authService.logOut()

        purgeLocalCredentials()
    }
}

// MARK: Local storage of user credentials
extension AnnotatoAuth {
    private var savedUserKey: String {
        "savedUser"
    }

    private func storeCredentialsLocally() {
        guard let currentUser = currentUser,
              let encodedUser = try? JSONEncoder().encode(currentUser) else {
            return
        }

        UserDefaults.standard.set(encodedUser, forKey: savedUserKey)
    }

    private func fetchLocalUserCredentials() -> AnnotatoUser? {
        guard let savedUser = UserDefaults.standard.object(forKey: savedUserKey) as? Data,
              let decodedUser = try? JSONDateDecoder().decode(AnnotatoUser.self, from: savedUser) else {
            return nil
        }

        return decodedUser
    }

    private func purgeLocalCredentials() {
        UserDefaults.standard.removeObject(forKey: savedUserKey)
    }
}
