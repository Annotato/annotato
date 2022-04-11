import AnnotatoSharedLibrary
import Foundation
import Combine

class AnnotatoAuth {
    private var authService: AnnotatoAuthService
    private let usersPersistenceManager = UsersPersistenceManager()
    private(set) var currentUser: AnnotatoUser?
    private var cancellables: Set<AnyCancellable> = []

    @Published private(set) var signUpIsSuccess = false
    @Published private(set) var logInIsSuccess = false
    @Published private(set) var signUpError: Error?
    @Published private(set) var logInError: Error?

    init() {
        self.authService = FirebaseAuth()

        setUser()
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
                storeCredentialsLocally(user: currentUser)
            }
        }
    }

    func logOut() {
        authService.logOut()

        purgeLocalCredentials()
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

// MARK: Local storage of user credentials
extension AnnotatoAuth {
    private var savedUserKey: String {
        "savedUser"
    }

    func storeCredentialsLocally(user: AnnotatoUser) {
        guard let encodedUser = try? JSONCustomEncoder().encode(user) else {
            return
        }

        UserDefaults.standard.set(encodedUser, forKey: savedUserKey)
    }

    private func purgeLocalCredentials() {
        UserDefaults.standard.removeObject(forKey: savedUserKey)
    }
}
