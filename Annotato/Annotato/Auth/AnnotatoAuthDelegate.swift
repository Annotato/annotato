protocol AnnotatoAuthDelegate: AnyObject {
    func logInDidFail(_ error: Error)
    func signUpDidFail(_ error: Error)
    func logInDidSucceed()
    func signUpDidSucceed()
}
