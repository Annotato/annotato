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

    func logIn(email: String, password: String) {
        authService.logIn(email: email, password: password)
    }

    func logOut() {
        authService.logOut()
        usersPersistenceManager.purgeSessionUser()
    }

    private func createUser(user: AnnotatoUser) {
        Task {
            guard await usersPersistenceManager.createUser(user: user) != nil else {
                return
            }

            self.signUpIsSuccess = true
        }
    }

    private func handleLoginSuccess(userId: String) {
        Task {
            await self.setUser(userId: userId)
            self.logInIsSuccess = true
        }
    }

    private func setUser(userId: String) async {
        self.currentUser = await usersPersistenceManager.getUser(userId: userId)

        if let currentUser = currentUser {
            usersPersistenceManager.saveSessionUser(user: currentUser)
        }
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

            self?.handleLoginSuccess(userId: userId)
        }).store(in: &cancellables)

        authService.signUpErrorPublisher.sink(receiveValue: { [weak self] error in
            self?.signUpError = error
        }).store(in: &cancellables)

        authService.logInErrorPublisher.sink(receiveValue: { [weak self] error in
            self?.logInError = error
        }).store(in: &cancellables)
    }
}
