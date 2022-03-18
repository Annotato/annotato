import UIKit

extension UIToolbar {
    var spaceBetween: UIBarButtonItem {
        let space = UIBarButtonItem(barButtonSystemItem: .fixedSpace, target: nil, action: nil)
        space.width = 10.0
        return space
    }

    var flexibleSpace: UIBarButtonItem {
        UIBarButtonItem(barButtonSystemItem: .flexibleSpace, target: self, action: nil)
    }
}
