import Foundation
import UIKit
import UniformTypeIdentifiers

protocol Navigable where Self: UIViewController {
    func goToAuth(asNewRootViewController: Bool)
    func goToDocumentList(asNewRootViewController: Bool)
    func goToDocumentEdit(documentId: UUID)
    func goToImportingFiles()
}

extension Navigable {
    func goToAuth(asNewRootViewController: Bool = false) {
        guard let authViewController = AuthViewController.instantiateFromStoryboard(.main) else {
            return
        }

        if asNewRootViewController {
            goToNewRootViewController(authViewController)
        } else {
            present(authViewController, animated: true, completion: nil)
        }
    }

    func goToDocumentList(asNewRootViewController: Bool = false) {
        guard let listViewController = DocumentListViewController.instantiateFullScreenFromStoryboard(
            .document
        ) else {
            return
        }

        if asNewRootViewController {
            goToNewRootViewController(listViewController)
        } else {
            present(listViewController, animated: true, completion: nil)
        }
    }

    private func goToNewRootViewController(_ newRootViewController: UIViewController) {
        (UIApplication.shared.connectedScenes.first?.delegate as? SceneDelegate)?
            .changeRootViewController(newRootViewController: newRootViewController, animated: true)
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

    func goToImportByCode() {
        guard let viewController = DocumentCodeImportViewController.instantiatePartialScreenFromStoryboard(
            .document
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

    func goBackWithRefresh() {
        goBack()
        presentingViewController?.viewWillAppear(true)
    }
}
