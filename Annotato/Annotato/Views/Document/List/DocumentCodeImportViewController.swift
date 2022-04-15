import UIKit

class DocumentCodeImportViewController: UIViewController, AlertPresentable, Navigable {
    private let documentSharePresenter = DocumentSharePresenter()

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
            let didCreateDocumentShare = await documentSharePresenter.createDocumentShare(documentId: documentId)
            if didCreateDocumentShare {
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
