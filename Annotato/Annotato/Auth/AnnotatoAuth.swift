import AnnotatoSharedLibrary

class AnnotatoAuth {
    private static let shared = AnnotatoAuth()
    private var authProvider: AnnotatoAuthAdapter = FirebaseAuth()

    private init() {}

    static var authUser: AnnotatoUser? {
        AnnotatoAuth.shared.authProvider.annotatoAuthUser
    }

    static var delegate: AnnotatoAuthDelegate? {
        get { AnnotatoAuth.shared.authProvider.delegate }
        set { AnnotatoAuth.shared.authProvider.delegate = newValue }
    }

    static func signUp(email: String, password: String, displayName: String) {
        AnnotatoAuth.shared.authProvider.signUp(email: email, password: password, displayName: displayName)
    }

    static func signIn(email: String, password: String) {
        AnnotatoAuth.shared.authProvider.signIn(email: email, password: password)
    }

    static func configure() {
        AnnotatoAuth.shared.authProvider.configure()
    }
}
