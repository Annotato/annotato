import UIKit
import AnnotatoSharedLibrary

class AuthViewController: UIViewController, Navigable {
    private let auth = AnnotatoAuth()

    // Storyboard UI Elements
    @IBOutlet private var formSegmentedControl: UISegmentedControl!
    @IBOutlet private var emailTextField: UITextField!
    @IBOutlet private var passwordTextField: UITextField!
    @IBOutlet private var displayNameTextField: UITextField!
    @IBOutlet private var submitButton: UIButton!
    @IBOutlet private var heightConstraint: NSLayoutConstraint!
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
        displayNameContainer.isHidden = true
        heightConstraint.constant = 50
    }

    @IBAction private func onSubmitButtonTapped(_ sender: UIButton) {
        testHttpRequests() // TODO: Remove after testing
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

    // TODO: Remove after testing
    private func testHttpRequests() {
        // Change these for testing
        let anExistingDocumentId = "d691bee0-0ddd-4ff8-a3d9-34ae69f850b6"
        let ownerIdOfExistingDocument = "owner1"

        Task {
            let documentsFetched = await DocumentsAPI()
                .getDocuments(userId: ownerIdOfExistingDocument)
            AnnotatoLogger.info("LIST \(documentsFetched)")

            let documentFetched = await DocumentsAPI()
                .getDocument(documentId: UUID(uuidString: anExistingDocumentId)!)
            AnnotatoLogger.info("GET \(documentFetched)")

            let documentToUpdate = Document(name: "Updated name", ownerId: ownerIdOfExistingDocument,
                                            baseFileUrl: "updated/path", id: UUID(uuidString: anExistingDocumentId)!)
            let updatedDocument = await DocumentsAPI().updateDocument(document: documentToUpdate)
            AnnotatoLogger.info("PUT \(updatedDocument)")

            let documentToCreate = Document(name: "Newly created document", ownerId: ownerIdOfExistingDocument,
                                            baseFileUrl: "path/to/new/document")
            let createdDocument = await DocumentsAPI().createDocument(document: documentToCreate)
            AnnotatoLogger.info("POST \(createdDocument)")

            let deletedDocument = await DocumentsAPI()
                .deleteDocument(document: Document(name: "", ownerId: "", baseFileUrl: "",
                                                   id: UUID(uuidString: anExistingDocumentId)!))
            AnnotatoLogger.info("DELETE \(deletedDocument)")
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
            heightConstraint.constant = 50
            submitButton.setTitle(logInButtonText, for: .normal)
        case .signUp:
            displayNameContainer.isHidden = false
            heightConstraint.constant = 30
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
