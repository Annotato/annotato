import Firebase
import AnnotatoSharedLibrary

class FirebaseAuth: AnnotatoAuthService {
    private static var isAlreadyConfigured = false

    @Published private(set) var newUser: AnnotatoUser?
    var newUserPublisher: Published<AnnotatoUser?>.Publisher { $newUser }

    @Published private(set) var loggedInUser: AnnotatoUser?
    var loggedInUserPublisher: Published<AnnotatoUser?>.Publisher { $loggedInUser }

    @Published private(set) var signUpError: Error?
    var signUpErrorPublisher: Published<Error?>.Publisher { $signUpError }

    @Published private(set) var logInError: Error?
    var logInErrorPublisher: Published<Error?>.Publisher { $logInError }

    init () {
        guard !FirebaseAuth.isAlreadyConfigured else {
            return
        }

        FirebaseApp.configure()
        FirebaseAuth.isAlreadyConfigured = true
    }

    private var currentFirebaseUser: User? {
        Auth.auth().currentUser
    }

    func signUp(email: String, password: String, displayName: String) {
        Auth.auth().createUser(withEmail: email, password: password) { authResult, error in
            if let error = error {
                AnnotatoLogger.error("When trying to sign up new user. \(error.localizedDescription)",
                                     context: "FirebaseAuth::signUp")
                self.signUpError = error
                return
            }

            self.setDisplayName(to: displayName, email: email)

            guard let id = authResult?.user.uid else {
                AnnotatoLogger.error("When trying to sign up new user. User info is missing",
                                     context: "FirebaseAuth::signUp")
                self.signUpError = error
                return
            }

            self.newUser = AnnotatoUser(email: email, displayName: displayName, id: id)
        }
    }

    func logIn(email: String, password: String) {
        Auth.auth().signIn(withEmail: email, password: password) { _, error in
            if let error = error {
                AnnotatoLogger.error("When trying to log in \(email). \(error.localizedDescription)",
                                     context: "FirebaseAuth::logIn")
                self.logInError = error
                return
            }

            AnnotatoLogger.info("\(email) logged in")
            self.loggedInUser = self.currentFirebaseUser?.toAnnotatoUser()
        }
    }

    func logOut() {
        guard let currentUserEmail = currentFirebaseUser?.email else {
            return
        }

        do {
            try Auth.auth().signOut()
            AnnotatoLogger.info("\(currentUserEmail) logged out")
        } catch {
            AnnotatoLogger.error("When trying to log out \(currentUserEmail). \(error.localizedDescription)",
                                 context: "FirebaseAuth::logOut")
        }
    }

    private func setDisplayName(to displayName: String, email: String) {
        let changeRequest = self.currentFirebaseUser?.createProfileChangeRequest()
        changeRequest?.displayName = displayName
        changeRequest?.commitChanges(completion: { error in
            if let error = error {
                AnnotatoLogger.error(
                    "Unable to set display name for \(email). \(error.localizedDescription)",
                    context: "FirebaseAuth::setDisplayName"
                )
                return
            }
            AnnotatoLogger.info("Display name for \(email) set to \(displayName)")
        })
    }
}

extension User {
    func toAnnotatoUser() -> AnnotatoUser {
        guard let email = email, let displayName = displayName else {
            fatalError("Unable to get user account info!")
        }

        return AnnotatoUser(email: email, displayName: displayName, id: uid)
    }
}
