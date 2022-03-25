import UIKit

class ShareViewController: UIViewController, AlertPresentable {
    var documentId: UUID?

    @IBOutlet private var documentCodeField: UITextField!
    @IBOutlet private var copyButton: UIButton!

    override func viewDidLoad() {
        super.viewDidLoad()

        documentCodeField.text = documentId?.description

        copyButton.tintColor = .darkGray
    }

    @IBAction private func didTapCopyButton(_ sender: UIButton) {
        UIPasteboard.general.string = documentCodeField.text
        presentSuccessAlert(successMessage: "Copied code to clipboard!")
    }
}
