import UIKit

protocol Navigable where Self: UIViewController {
    func goToGallery()
}

extension Navigable {
    func goToGallery() {
        guard let viewController = GalleryViewController.instantiateFullScreenFromStoryboard(
            .gallery
        ) else {
            return
        }

        present(viewController, animated: true, completion: nil)
    }
}
