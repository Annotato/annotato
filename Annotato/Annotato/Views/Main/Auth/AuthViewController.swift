import UIKit

import AnnotatoSharedLibrary // TODO: REMOVE THESE TEST LINES

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

        // TODO: REMOVE THESE TEST LINES

        let uuid = UUID(uuidString: "b156cee5-b26b-4c77-8fd8-b62cf2bb4de9")

        let testDocument = Document(id: uuid, name: "test doc", ownerId: "user", baseFileUrl: "path/to/document")
        let annotation1 = Annotation(origin: .zero, width: 100, ownerId: "user", documentId: testDocument.id)
        let annotation2 = Annotation(origin: CGPoint(x: 100, y: 100), width: 100,
                                     ownerId: "user", documentId: testDocument.id)

        testDocument.addAnnotation(annotation: annotation1)
        testDocument.addAnnotation(annotation: annotation2)

        // CREATE
//         Task {
//             let resp = await DocumentsAPI().createDocument(document: testDocument)
//             print("CREATE", resp)
//         }

        // READ
//        Task {
//            let resp = await DocumentsAPI().getDocument(documentId: testDocument.id)
//            print("READ", resp)
//        }

        // LIST
//        Task {
//            let resp = await DocumentsAPI().getDocuments(userId: "user")
//            print("LIST", resp)
//        }

        // UPDATE (change document name and remove all annotations)
//        Task {
//            let updated = Document(id: uuid,
//                                   name: "update test doc 3", ownerId: "user",
//                                   baseFileUrl: "path/to/document")
//            let resp = await DocumentsAPI().updateDocument(document: updated)
//            print("UPDATE", resp)
//        }

        // UPDATE (add annotation. should be 3 annotations)
//        Task {
//            testDocument.addAnnotation(
//                annotation: Annotation(origin: .zero,
//                                       width: 100, ownerId: "user",
//                                       documentId: testDocument.id))
//            let resp = await DocumentsAPI().updateDocument(document: testDocument)
//            print("UPDATE", resp)
//        }

        // DELETE
//        Task {
//            let resp = await DocumentsAPI().deleteDocument(document: testDocument)
//            print("DELETE", resp)
//        }
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
