import AnnotatoSharedLibrary
import Foundation
import Combine

class AuthViewModel {
    private var authService: AnnotatoAuthService
    private let usersPersistenceManager = UsersPersistenceManager()
    private(set) var currentUser: AnnotatoUser?
    private var cancellables: Set<AnyCancellable> = []

    @Published private(set) var signUpIsSuccess = false
    @Published private(set) var logInIsSuccess = false
    @Published private(set) var signUpError: Error?
    @Published private(set) var logInError: Error?

    init() {
        self.authService = FirebaseAuthService()
        self.currentUser = usersPersistenceManager.fetchSessionUser()

        setUpSubscribers()
    }

    func signUp(email: String, password: String, displayName: String) {
        authService.signUp(email: email, password: password, displayName: displayName)
    }

    private func createUser(user: AnnotatoUser) {
        Task {
            guard await usersPersistenceManager.createUser(user: user) != nil else {
                return
            }

            self.signUpIsSuccess = true
        }
    }

    func logIn(email: String, password: String) {
        authService.logIn(email: email, password: password)
    }

    private func setUser(userId: String = "") {
        Task {
            self.currentUser = await usersPersistenceManager.getUser(userId: userId)

            if let currentUser = currentUser {
                usersPersistenceManager.saveSessionUser(user: currentUser)
            }
        }
    }

    func logOut() {
        authService.logOut()
        usersPersistenceManager.purgeSessionUser()
    }

    private func setUpSubscribers() {
        authService.newUserPublisher.sink(receiveValue: { [weak self] newUser in
            guard let newUser = newUser else {
                return
            }

            self?.createUser(user: newUser)
        }).store(in: &cancellables)

        authService.loggedInUserPublisher.sink(receiveValue: { [weak self] existingUser in
            guard let userId = existingUser?.id else {
                return
            }

            self?.setUser(userId: userId)
            self?.logInIsSuccess = true
        }).store(in: &cancellables)

        authService.signUpErrorPublisher.sink(receiveValue: { [weak self] error in
            self?.signUpError = error
        }).store(in: &cancellables)

        authService.logInErrorPublisher.sink(receiveValue: { [weak self] error in
            self?.logInError = error
        }).store(in: &cancellables)
    }
}
