import AnnotatoSharedLibrary

class AnnotatoAuth {
    private static let shared = AnnotatoAuth()
    private var authProvider: AnnotatoAuthAdapter = FirebaseAuth()

    private init() {}

    static var currentUser: AnnotatoUser? {
        AnnotatoAuth.shared.authProvider.currentUser
    }

    static var delegate: AnnotatoAuthDelegate? {
        get { AnnotatoAuth.shared.authProvider.delegate }
        set { AnnotatoAuth.shared.authProvider.delegate = newValue }
    }

    static func signUp(email: String, password: String, displayName: String) {
        AnnotatoAuth.shared.authProvider.signUp(email: email, password: password, displayName: displayName)
    }

    static func logIn(email: String, password: String) {
        AnnotatoAuth.shared.authProvider.logIn(email: email, password: password)
    }

    static func configure() {
        AnnotatoAuth.shared.authProvider.configure()
    }
}
