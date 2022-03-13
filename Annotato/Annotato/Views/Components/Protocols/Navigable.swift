import UIKit
import UniformTypeIdentifiers

protocol Navigable where Self: UIViewController {
    func goToDocumentList()
    func goToDocumentEdit()
    func goToImportingFiles()
    func goToDocumentEdit(documentPdfViewModel: DocumentPdfViewModel)
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

    func goToDocumentEdit(documentPdfViewModel: DocumentPdfViewModel) {
        guard let viewController = DocumentEditViewController.instantiateFullScreenFromStoryboard(
            .document, documentPdfViewModel: documentPdfViewModel
        ) else {
            return
        }
        present(viewController, animated: true, completion: nil)
    }

    func goToImportingFiles() {
        let documentPicker = UIDocumentPickerViewController(forOpeningContentTypes: [UTType.pdf], asCopy: true)
        documentPicker.delegate = self as? UIDocumentPickerDelegate
        documentPicker.allowsMultipleSelection = false
        documentPicker.modalPresentationStyle = .fullScreen
        present(documentPicker, animated: true, completion: nil)
    }
}
