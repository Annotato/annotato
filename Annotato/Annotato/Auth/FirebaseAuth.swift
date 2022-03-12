import Firebase
import AnnotatoSharedLibrary

class FirebaseAuth: AnnotatoAuthAdapter {
    weak var delegate: AnnotatoAuthDelegate?

    private var firebaseAuthUser: User? {
        Auth.auth().currentUser
    }

    var annotatoAuthUser: AnnotatoUser? {
        firebaseAuthUser?.toAnnotatoAuthUser()
    }

    func configure() {
        FirebaseApp.configure()
    }

    func signUp(email: String, password: String, displayName: String) {
        Auth.auth().createUser(withEmail: email, password: password) { _, error in
            guard error == nil else {
                AnnotatoLogger.error("When trying to sign up new user. \(error!.localizedDescription)")
                self.delegate?.signUpDidFail(error!)
                return
            }

            self.setDisplayName(to: displayName, email: email)
            self.delegate?.signUpDidSucceed()
        }
    }

    func signIn(email: String, password: String) {
        Auth.auth().signIn(withEmail: email, password: password) { _, error in
            guard error == nil else {
                AnnotatoLogger.error("When trying to log in \(email). \(error!.localizedDescription)")
                self.delegate?.signInDidFail(error!)
                return
            }

            AnnotatoLogger.info("\(email) logged in")
            self.delegate?.signInDidSucceed()
        }
    }

    private func setDisplayName(to displayName: String, email: String) {
        let changeRequest = self.firebaseAuthUser?.createProfileChangeRequest()
        changeRequest?.displayName = displayName
        changeRequest?.commitChanges(completion: { error in
            guard error == nil else {
                AnnotatoLogger.error("Unable to set display name for \(email)")
                return
            }
            AnnotatoLogger.info("Display name for \(email) set to \(displayName)")
        })
    }
}

extension User {
    func toAnnotatoAuthUser() -> AnnotatoUser {
        guard let email = email, let displayName = displayName else {
            fatalError("Unable to get user account info!")
        }

        return AnnotatoUser(uid: uid, email: email, displayName: displayName)
    }
}
