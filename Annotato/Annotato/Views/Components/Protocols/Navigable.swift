import UIKit

protocol Navigable where Self: UIViewController {
    func goToDocumentList()
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

    func goBack() {
        self.dismiss(animated: true, completion: nil)
    }
}
