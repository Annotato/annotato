import AnnotatoSharedLibrary

protocol AnnotatoAuthAdapter {
    var delegate: AnnotatoAuthDelegate? { get set }
    var annotatoAuthUser: AnnotatoUser? { get }
    func signUp(email: String, password: String, displayName: String)
    func signIn(email: String, password: String)
    func configure()
}
