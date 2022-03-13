import AnnotatoSharedLibrary

protocol AnnotatoAuthService {
    var delegate: AnnotatoAuthDelegate? { get set }
    var currentUser: AnnotatoUser? { get }
    func signUp(email: String, password: String, displayName: String)
    func logIn(email: String, password: String)
}
