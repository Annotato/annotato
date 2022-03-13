import UIKit

enum Storyboard: String {
    case document = "Document"
    case main = "Main"

    var instance: UIStoryboard {
        UIStoryboard(name: self.rawValue, bundle: .main)
    }

    func viewController<T: UIViewController>(viewControllerClass: T.Type) -> T? {
        let storyboardId = viewControllerClass.storyboardId
        return instance.instantiateViewController(withIdentifier: storyboardId) as? T
    }
}
