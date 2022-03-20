import UIKit

class AuthViewController: UIViewController, Navigable {
    private let auth = AnnotatoAuth()

    // Storyboard UI Elements
    @IBOutlet private var formSegmentedControl: UISegmentedControl!
    @IBOutlet private var emailTextField: UITextField!
    @IBOutlet private var passwordTextField: UITextField!
    @IBOutlet private var displayNameTextField: UITextField!
    @IBOutlet private var submitButton: UIButton!
    @IBOutlet private var heightConstraint: NSLayoutConstraint!
    @IBOutlet private var mainContainer: UIView!
    @IBOutlet private var displayNameContainer: UIView!

    private enum Segment: Int {
        case logIn
        case signUp
    }

    private let logInButtonText = "Log In"
    private let signUpButtonText = "Sign Up"

    override func viewDidLoad() {
        super.viewDidLoad()

        auth.delegate = self
        mainContainer.layer.cornerRadius = 25
        displayNameContainer.isHidden = true
        heightConstraint.constant = 35

        emailTextField.attributedPlaceholder = NSAttributedString(
            string: "Email",
            attributes: [NSAttributedString.Key.foregroundColor: UIColor.black]
        )
        passwordTextField.attributedPlaceholder = NSAttributedString(
            string: "Password",
            attributes: [NSAttributedString.Key.foregroundColor: UIColor.black]
        )
        displayNameTextField.attributedPlaceholder = NSAttributedString(
            string: "Display Name",
            attributes: [NSAttributedString.Key.foregroundColor: UIColor.black]
        )
    }

    @IBAction private func onSubmitButtonTapped(_ sender: UIButton) {
        let segment = Segment(rawValue: formSegmentedControl.selectedSegmentIndex)
        switch segment {
        case .logIn:
            auth.logIn(email: emailTextField.text ?? "", password: passwordTextField.text ?? "")
        case .signUp:
            guard !(displayNameTextField.text ?? "").isEmpty else {
                presentErrorAlert(errorMessage: "Display Name cannot be empty.")
                return
            }

            auth.signUp(
                email: emailTextField.text ?? "",
                password: passwordTextField.text ?? "",
                displayName: displayNameTextField.text ?? ""
            )
        default:
            fatalError("Invalid Segment")
        }
    }

    @IBAction private func onFormActionChanged(_ sender: UISegmentedControl) {
        updateFormViews()
    }

    private func updateFormViews() {
        let segment = Segment(rawValue: formSegmentedControl.selectedSegmentIndex)
        switch segment {
        case .logIn:
            displayNameContainer.isHidden = true
            heightConstraint.constant = 35
            submitButton.setTitle(logInButtonText, for: .normal)
        case .signUp:
            displayNameContainer.isHidden = false
            heightConstraint.constant = 15
            submitButton.setTitle(signUpButtonText, for: .normal)
        default:
            fatalError("Invalid Segment")
        }
    }
}

extension AuthViewController: AnnotatoAuthDelegate, AlertPresentable {
    func logInDidFail(_ error: Error) {
        presentErrorAlert(errorMessage: error.localizedDescription)
    }

    func signUpDidFail(_ error: Error) {
        presentErrorAlert(errorMessage: error.localizedDescription)
    }

    func logInDidSucceed() {
        goToDocumentList()
    }

    func signUpDidSucceed() {
        presentTimedAlert(title: "Sign Up Successful!", message: "Please log in to use the application.")
        formSegmentedControl.selectedSegmentIndex = Segment.logIn.rawValue
        updateFormViews()
    }
}
