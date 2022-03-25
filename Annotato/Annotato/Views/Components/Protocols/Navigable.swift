import Foundation
import UIKit
import UniformTypeIdentifiers

protocol Navigable where Self: UIViewController {
    func goToDocumentList()
    func goToDocumentEdit()
    func goToDocumentEdit(documentId: UUID)
    func goToImportingFiles()
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

    func goToDocumentEdit(documentId: UUID) {
        guard let viewController = DocumentEditViewController.instantiateFullScreenFromStoryboard(
            .document
        ) else {
            return
        }
        viewController.documentId = documentId
        present(viewController, animated: true, completion: nil)
    }

    func goToImportingFiles() {
        let documentPicker = UIDocumentPickerViewController(forOpeningContentTypes: [UTType.pdf], asCopy: true)
        documentPicker.delegate = self as? UIDocumentPickerDelegate
        documentPicker.allowsMultipleSelection = false
        documentPicker.modalPresentationStyle = .fullScreen
        present(documentPicker, animated: true, completion: nil)
    }

    func goToShare(documentId: UUID) {
        guard let viewController = ShareViewController.instantiatePartialScreenFromStoryboard(
            .document
        ) else {
            return
        }
        viewController.documentId = documentId
        present(viewController, animated: true, completion: nil)
    }

    func goBack() {
        self.dismiss(animated: true, completion: nil)
    }
}
