import AnnotatoSharedLibrary

class AnnotatoAuth {
    private static let shared = AnnotatoAuth()
    private var authService: AnnotatoAuthService = FirebaseAuth()

    private init() {}

    static var currentUser: AnnotatoUser? {
        AnnotatoAuth.shared.authService.currentUser
    }

    static var delegate: AnnotatoAuthDelegate? {
        get { AnnotatoAuth.shared.authService.delegate }
        set { AnnotatoAuth.shared.authService.delegate = newValue }
    }

    static func signUp(email: String, password: String, displayName: String) {
        AnnotatoAuth.shared.authService.signUp(email: email, password: password, displayName: displayName)
    }

    static func logIn(email: String, password: String) {
        AnnotatoAuth.shared.authService.logIn(email: email, password: password)
    }

    static func configure() {
        AnnotatoAuth.shared.authService.configure()
    }
}
