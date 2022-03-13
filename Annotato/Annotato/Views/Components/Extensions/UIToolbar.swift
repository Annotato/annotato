import UIKit

extension UIToolbar {
    func makeFlexibleSpace() -> UIBarButtonItem {
        UIBarButtonItem(barButtonSystemItem: .flexibleSpace, target: self, action: nil)
    }
}
