protocol AnnotatoAuthDelegate: AnyObject {
    func signInDidFail(_ error: Error)
    func signUpDidFail(_ error: Error)
    func signInDidSucceed()
    func signUpDidSucceed()
}
