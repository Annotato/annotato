import UIKit

class DocumentCodeImportViewController: UIViewController, AlertPresentable {
    @IBOutlet private var documentCodeField: UITextField!

    @IBAction private func didTapImportButton(_ sender: UIButton) {
        importDocument()
    }

    private func importDocument() {
        let code = documentCodeField.text ?? ""

        if code.isEmptyOrWhitespaceOnly {
            presentErrorAlert(errorMessage: "Please enter a code")
        }
    }
}
