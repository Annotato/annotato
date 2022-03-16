import UIKit

// MARK: Navigation
extension UIViewController {
    // Each view controller storyboardID should be set to its class name
    class var storyboardId: String {
        "\(self)"
    }

    static func instantiateFromStoryboard(_ storyboard: Storyboard) -> Self? {
        storyboard.viewController(viewControllerClass: self)
    }

    static func instantiateFullScreenFromStoryboard(_ storyboard: Storyboard) -> Self? {
        let viewController = instantiateFromStoryboard(storyboard)

        viewController?.modalPresentationStyle = .fullScreen

        return viewController
    }

    static func instantiatePartialScreenFromStoryboard(storyboard: Storyboard) -> Self? {
        let viewController = instantiateFromStoryboard(storyboard)

        viewController?.isModalInPresentation = true

        return viewController
    }
}

// MARK: Safe Area
extension UIViewController {
    var margins: UILayoutGuide {
        view.layoutMarginsGuide
    }

    var frame: CGRect {
        margins.layoutFrame
    }
}
