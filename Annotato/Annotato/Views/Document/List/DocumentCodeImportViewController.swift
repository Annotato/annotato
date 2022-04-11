import UIKit

class DocumentCodeImportViewController: UIViewController, AlertPresentable, Navigable {
    private let documentShareController = DocumentShareController()

    @IBOutlet private var documentCodeField: UITextField!

    @IBAction private func didTapImportButton(_ sender: UIButton) {
        importDocument()
    }

    private func importDocument() {
        let code = documentCodeField.text ?? ""

        guard !code.isEmptyOrWhitespaceOnly else {
            presentErrorAlert(errorMessage: "Please enter a code")
            return
        }

        guard let documentId = UUID(uuidString: code) else {
            presentErrorAlert(errorMessage: "Please enter a valid code")
            return
        }

        Task {
            let documentShare = await documentShareController.createDocumentShare(documentId: documentId)
            if documentShare != nil {
                presentSuccessAlert(
                    successMessage: "Successfully imported document!",
                    completion: goBackWithRefresh
                )
            } else {
                presentErrorAlert(
                    errorMessage: "The document was not imported. It may already exist in your collection")
            }
        }
    }
}
