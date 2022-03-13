import Firebase
import AnnotatoSharedLibrary

class FirebaseAuth: AnnotatoAuthService {
    static var isAlreadyConfigured = false

    init () {
        if !FirebaseAuth.isAlreadyConfigured {
            FirebaseApp.configure()
            FirebaseAuth.isAlreadyConfigured = true
        }
    }

    weak var delegate: AnnotatoAuthDelegate?

    private var currentFirebaseUser: User? {
        Auth.auth().currentUser
    }

    var currentUser: AnnotatoUser? {
        currentFirebaseUser?.toAnnotatoUser()
    }

    func signUp(email: String, password: String, displayName: String) {
        Auth.auth().createUser(withEmail: email, password: password) { _, error in
            if let error = error {
                AnnotatoLogger.error("When trying to sign up new user. \(error.localizedDescription)",
                                     context: "FirebaseAuth::signUp")
                self.delegate?.signUpDidFail(error)
                return
            }

            self.setDisplayName(to: displayName, email: email)
            self.delegate?.signUpDidSucceed()
        }
    }

    func logIn(email: String, password: String) {
        Auth.auth().signIn(withEmail: email, password: password) { _, error in
            if let error = error {
                AnnotatoLogger.error("When trying to log in \(email). \(error.localizedDescription)",
                                     context: "FirebaseAuth::logIn")
                self.delegate?.logInDidFail(error)
                return
            }

            AnnotatoLogger.info("\(email) logged in")
            self.delegate?.logInDidSucceed()
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

        return AnnotatoUser(uid: uid, email: email, displayName: displayName)
    }
}
