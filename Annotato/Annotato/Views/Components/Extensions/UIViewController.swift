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

    static func instantiatePartialScreenFromStoryboard(_ storyboard: Storyboard) -> Self? {
        let viewController = instantiateFromStoryboard(storyboard)

        viewController?.modalPresentationStyle = .formSheet

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

// MARK: Offline To Online
extension UIViewController {
    var onlineAlertController: UIAlertController {
        let alertController = UIAlertController(title: "Welcome back online!",
                                                message: "Choose your merge strategy.",
                                                preferredStyle: .alert)

        alertController.addAction(UIAlertAction(title: "Discard Local Changes",
                                                style: .default) { _ in
            OfflineToOnlineWebSocketManager().sendOnlineMessage(mergeStrategy: .keepServerVersion)
        })

        alertController.addAction(UIAlertAction(title: "Override with Local Changes",
                                                style: .default) { _ in
            OfflineToOnlineWebSocketManager().sendOnlineMessage(mergeStrategy: .keepServerVersion)
        })

        return alertController
    }

    func presentOnlineAlert() {

    }
}
