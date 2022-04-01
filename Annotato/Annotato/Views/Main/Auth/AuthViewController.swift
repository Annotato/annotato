import UIKit
import AnnotatoSharedLibrary // TODO: REMOVE AFTER TESTING

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
            attributes: [NSAttributedString.Key.foregroundColor: UIColor.darkGray]
        )
        passwordTextField.attributedPlaceholder = NSAttributedString(
            string: "Password",
            attributes: [NSAttributedString.Key.foregroundColor: UIColor.darkGray]
        )
        displayNameTextField.attributedPlaceholder = NSAttributedString(
            string: "Display Name",
            attributes: [NSAttributedString.Key.foregroundColor: UIColor.darkGray]
        )

        // TODO: REMOVE AFTER TESTING

        // testCreateAnnotation()

        // testUpdateAnnotation()

        // testCreateDocument()

        testUpdateDocument()
    }

    // TODO: REMOVE AFTER TESTING

    private func testUpdateAnnotation() {
        let docUUID = UUID(uuidString: "33629713-2871-4a0a-9935-0a7eae0c28d0")!
        let a1UUID = UUID(uuidString: "82e6ab7d-c17e-49cb-9f7d-a28135e4092b")!
        let a2UUID = UUID(uuidString: "b2afe130-597f-4853-9162-2c8e6f9d401e")!

        let selectionBoxA1 = SelectionBox(startPoint: .zero, endPoint: .zero,
                                          annotationId: a1UUID, id: UUID(), createdAt: Date(),
                                          updatedAt: nil, deletedAt: nil)
        let selectionBoxA2 = SelectionBox(startPoint: .zero, endPoint: .zero,
                                          annotationId: a2UUID, id: UUID(), createdAt: Date(),
                                          updatedAt: nil, deletedAt: nil)

        let part = AnnotationText(type: .plainText, content: "I love this stupid testing", height: 100,
                                  order: 1, annotationId: a2UUID, id: UUID(), createdAt: Date(),
                                  updatedAt: nil, deletedAt: nil)

        var annotation1 = Annotation(origin: .zero, width: 100, parts: [], selectionBox: selectionBoxA1,
                                     ownerId: "owner", documentId: docUUID, id: a1UUID,
                                     createdAt: Date(), updatedAt: nil, deletedAt: nil)

        var annotation2 = Annotation(origin: .zero, width: 100, parts: [part],
                                     selectionBox: selectionBoxA2,
                                     ownerId: "owner", documentId: docUUID, id: a2UUID,
                                     createdAt: Date(), updatedAt: nil, deletedAt: nil)

        let document = Document(name: "test", ownerId: "owner", baseFileUrl: "file",
                                annotations: [], id: docUUID, createdAt: Date(), updatedAt: nil,
                                deletedAt: nil)

        // Create Doc
        _ = LocalDocumentsPersistence().createDocument(document: document)

        // Create A1
        _ = LocalAnnotationsPersistence().createAnnotation(annotation: annotation1)

        // Create A2
        _ = LocalAnnotationsPersistence().createAnnotation(annotation: annotation2)

        annotation1 = Annotation(origin: annotation1.origin, width: annotation1.width,
                                 parts: annotation1.parts, selectionBox: selectionBoxA1,
                                 ownerId: "ownerUpdated", documentId: docUUID, id: a1UUID,
                                 createdAt: Date(), updatedAt: nil, deletedAt: nil)

        annotation2 = Annotation(origin: annotation2.origin, width: annotation2.width,
                                 parts: annotation2.parts, selectionBox: selectionBoxA2,
                                 ownerId: "ownerUpdate", documentId: docUUID, id: a2UUID,
                                 createdAt: Date(), updatedAt: nil, deletedAt: nil)

        _ = LocalAnnotationsPersistence().updateAnnotation(annotation: annotation1)
        _ = LocalAnnotationsPersistence().updateAnnotation(annotation: annotation2)
    }

    private func testCreateAnnotation() {
        let docUUID = UUID(uuidString: "33629713-2871-4a0a-9935-0a7eae0c28d0")!
        let a1UUID = UUID(uuidString: "82e6ab7d-c17e-49cb-9f7d-a28135e4092b")!
        let a2UUID = UUID(uuidString: "b2afe130-597f-4853-9162-2c8e6f9d401e")!

        let selectionBoxA1 = SelectionBox(startPoint: .zero, endPoint: .zero,
                                          annotationId: a1UUID, id: UUID(), createdAt: Date(),
                                          updatedAt: nil, deletedAt: nil)
        let selectionBoxA2 = SelectionBox(startPoint: .zero, endPoint: .zero,
                                          annotationId: a2UUID, id: UUID(), createdAt: Date(),
                                          updatedAt: nil, deletedAt: nil)

        let part = AnnotationText(type: .plainText, content: "I love this stupid testing", height: 100,
                                  order: 1, annotationId: a2UUID, id: UUID(), createdAt: Date(),
                                  updatedAt: nil, deletedAt: nil)

        let annotation1 = Annotation(origin: .zero, width: 100, parts: [], selectionBox: selectionBoxA1,
                                     ownerId: "owner", documentId: docUUID, id: a1UUID,
                                     createdAt: Date(), updatedAt: nil, deletedAt: nil)

        let annotation2 = Annotation(origin: .zero, width: 100, parts: [part],
                                     selectionBox: selectionBoxA2,
                                     ownerId: "owner", documentId: docUUID, id: a2UUID,
                                     createdAt: Date(), updatedAt: nil, deletedAt: nil)

        let document = Document(name: "test", ownerId: "owner", baseFileUrl: "file",
                                annotations: [], id: docUUID, createdAt: Date(), updatedAt: nil,
                                deletedAt: nil)

        _ = LocalDocumentsPersistence().createDocument(document: document)

        // Without parts
        _ = LocalAnnotationsPersistence().createAnnotation(annotation: annotation1)

        // With parts
        // _ = LocalAnnotationsPersistence().createAnnotation(annotation: annotation2)

    }

    private func testCreateDocument() {
        let docUUID = UUID(uuidString: "33629713-2871-4a0a-9935-0a7eae0c28d0")!
        let a1UUID = UUID(uuidString: "82e6ab7d-c17e-49cb-9f7d-a28135e4092b")!
        let a2UUID = UUID(uuidString: "b2afe130-597f-4853-9162-2c8e6f9d401e")!

        let selectionBoxA1 = SelectionBox(startPoint: .zero, endPoint: .zero,
                                          annotationId: a1UUID, id: UUID(), createdAt: Date(),
                                          updatedAt: nil, deletedAt: nil)
        let selectionBoxA2 = SelectionBox(startPoint: .zero, endPoint: .zero,
                                          annotationId: a2UUID, id: UUID(), createdAt: Date(),
                                          updatedAt: nil, deletedAt: nil)

        let part = AnnotationText(type: .plainText, content: "I love this stupid testing", height: 100,
                                  order: 1, annotationId: a2UUID, id: UUID(), createdAt: Date(),
                                  updatedAt: nil, deletedAt: nil)

        let annotation1 = Annotation(origin: .zero, width: 100, parts: [],
                                     selectionBox: selectionBoxA1,
                                     ownerId: "owner", documentId: docUUID, id: a1UUID,
                                     createdAt: Date(), updatedAt: nil, deletedAt: nil)

        let annotation2 = Annotation(origin: .zero, width: 100, parts: [part],
                                     selectionBox: selectionBoxA2,
                                     ownerId: "owner", documentId: docUUID, id: a2UUID,
                                     createdAt: Date(), updatedAt: nil, deletedAt: nil)

        // MARK: CREATE

        // Create document ✅
        // let document = Document(name: "test", ownerId: "owner", baseFileUrl: "file",
        //                        annotations: [], id: docUUID, createdAt: Date(), updatedAt: nil,
        //                        deletedAt: nil)

        // Create document with annotation ✅
        // let document = Document(name: "test", ownerId: "owner", baseFileUrl: "file",
        //                        annotations: [annotation1], id: docUUID, createdAt: Date(),
        //                        updatedAt: nil,deletedAt: nil)

        // Create document with annotation with some parts inside ✅
        // let document = Document(name: "test", ownerId: "owner", baseFileUrl: "file",
        //                         annotations: [annotation2], id: docUUID, createdAt: Date(),
        //                         updatedAt: nil, deletedAt: nil)

        // LocalDocumentsPersistence().createDocument(document: document)
    }

    private func testUpdateDocument() {
        let docUUID = UUID(uuidString: "33629713-2871-4a0a-9935-0a7eae0c28d0")!
        let a1UUID = UUID(uuidString: "82e6ab7d-c17e-49cb-9f7d-a28135e4092b")!
        let a2UUID = UUID(uuidString: "b2afe130-597f-4853-9162-2c8e6f9d401e")!

        let selectionBoxA1 = SelectionBox(startPoint: .zero, endPoint: .zero,
                                          annotationId: a1UUID, id: UUID(), createdAt: Date(),
                                          updatedAt: nil, deletedAt: nil)
        let selectionBoxA2 = SelectionBox(startPoint: .zero, endPoint: .zero,
                                          annotationId: a2UUID, id: UUID(), createdAt: Date(),
                                          updatedAt: nil, deletedAt: nil)

        let part = AnnotationText(type: .plainText, content: "I love this stupid testing", height: 100,
                                  order: 1, annotationId: a2UUID, id: UUID(), createdAt: Date(),
                                  updatedAt: nil, deletedAt: nil)

        let annotation1 = Annotation(origin: .zero, width: 100, parts: [],
                                     selectionBox: selectionBoxA1,
                                     ownerId: "owner", documentId: docUUID, id: a1UUID,
                                     createdAt: Date(), updatedAt: nil, deletedAt: nil)

        let annotation2 = Annotation(origin: .zero, width: 100, parts: [part],
                                     selectionBox: selectionBoxA2,
                                     ownerId: "owner", documentId: docUUID, id: a2UUID,
                                     createdAt: Date(), updatedAt: nil, deletedAt: nil)

        var document = Document(name: "test", ownerId: "owner", baseFileUrl: "file",
                                annotations: [], id: docUUID, createdAt: Date(), updatedAt: nil,
                                deletedAt: nil)

        // Create Doc
        //   _ = LocalDocumentsPersistence().createDocument(document: document)

        // document = Document(name: "testUpdated", ownerId: "owner", baseFileUrl: "file",
        //                     annotations: [], id: docUUID, createdAt: Date(), updatedAt: nil,
        //                     deletedAt: nil)

        // _ = LocalDocumentsPersistence().updateDocument(document: document)

        // document = Document(name: "testUpdated", ownerId: "owner", baseFileUrl: "file",
        //                     annotations: [annotation1], id: docUUID, createdAt: Date(),
        //                     updatedAt: nil, deletedAt: nil)

        // _ = LocalDocumentsPersistence().updateDocument(document: document)

        // document = Document(name: "testUpdated", ownerId: "owner", baseFileUrl: "file",
        //                     annotations: [annotation1, annotation2], id: docUUID, createdAt: Date(),
        //                     updatedAt: nil, deletedAt: nil)

        // _ = LocalDocumentsPersistence().updateDocument(document: document)
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
        goToDocumentList(asNewRootViewController: true)
    }

    func signUpDidSucceed() {
        presentTimedAlert(title: "Sign Up Successful!", message: "Please log in to use the application.")
        formSegmentedControl.selectedSegmentIndex = Segment.logIn.rawValue
        updateFormViews()
    }
}
