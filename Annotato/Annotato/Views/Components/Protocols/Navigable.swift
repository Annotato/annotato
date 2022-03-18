import UIKit
import UniformTypeIdentifiers

protocol Navigable where Self: UIViewController {
    func goToDocumentList()
    func goToDocumentEdit()
    func goToDocumentEdit(documentViewModel: DocumentViewModel)
    func goToImportingFiles()
    func goToDocumentEdit(documentPdfViewModel: PdfViewModel)
}

extension Navigable {
    func goToDocumentList() {
        guard let viewController = DocumentListViewController.instantiateFullScreenFromStoryboard(
            .document
        ) else {
            return
        }
        present(viewController, animated: true, completion: nil)
    }

    func goToDocumentEdit() {
        guard let viewController = DocumentEditViewController.instantiateFullScreenFromStoryboard(
            .document
        ) else {
            return
        }
        present(viewController, animated: true, completion: nil)
    }

    func goToDocumentEdit(documentPdfViewModel: PdfViewModel) {
        guard let viewController = DocumentEditViewController.instantiateFullScreenFromStoryboard(
            .document
        ) else {
            return
        }
        viewController.currentDocumentViewModel = documentViewModel
        present(viewController, animated: true, completion: nil)
    }

    func goToImportingFiles() {
        let documentPicker = UIDocumentPickerViewController(forOpeningContentTypes: [UTType.pdf], asCopy: true)
        documentPicker.delegate = self as? UIDocumentPickerDelegate
        documentPicker.allowsMultipleSelection = false
        documentPicker.modalPresentationStyle = .fullScreen
        present(documentPicker, animated: true, completion: nil)
    }

    func goBack() {
        self.dismiss(animated: true, completion: nil)
    }
}
