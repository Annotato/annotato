import UIKit

protocol Navigable where Self: UIViewController {
    func goToGallery()
}

extension Navigable {
    func goToGallery() {
        guard let viewController = DocumentListViewController.instantiateFullScreenFromStoryboard(
            .document
        ) else {
            return
        }

        present(viewController, animated: true, completion: nil)
    }
}
