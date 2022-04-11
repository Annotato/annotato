import AnnotatoSharedLibrary
import Combine

protocol AnnotatoAuthService {
    func signUp(email: String, password: String, displayName: String)
    func logIn(email: String, password: String)
    func logOut()

    var newUserPublisher: Published<AnnotatoUser?>.Publisher { get }
    var existingUserPublisher: Published<AnnotatoUser?>.Publisher { get }
    var signUpErrorPublisher: Published<Error?>.Publisher { get }
    var logInErrorPublisher: Published<Error?>.Publisher { get }
}
