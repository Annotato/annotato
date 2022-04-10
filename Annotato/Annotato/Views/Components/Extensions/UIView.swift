import UIKit

extension UIView {
    func showSelected() {
        let oldColor = backgroundColor
        let duration = 0.2
        let red: CGFloat = 253 / 255
        let green: CGFloat = 242 / 255
        let blue: CGFloat = 187 / 255
        let alpha: CGFloat = 1.0
        let color = UIColor(red: red, green: green, blue: blue, alpha: alpha)

        UIView.animate(
            withDuration: duration,
            animations: {
                self.backgroundColor = color
            },
            completion: { _ in
                UIView.animate(withDuration: duration) {
                    self.backgroundColor = oldColor
                }
            }
        )
    }

    func replaceSubview<T: UIView>(newSubview: T) {
        subviews.filter { $0 is T }.forEach { $0.removeFromSuperview() }
        addSubview(newSubview)
    }

    func bringToFrontOfSuperview() {
        self.superview?.bringSubviewToFront(self)
    }

    class func makeToggleableSystemButton(systemName: String, color: UIColor) -> ToggleableButton {
        let button = ToggleableButton()
        button.setImage(UIImage(systemName: systemName), for: .normal)
        button.tintColor = color
        return button
    }

    class func makeDeleteButton() -> UIButton {
        let button = UIButton()
        let imageName = SystemImageName.trash.rawValue
        button.setImage(UIImage(systemName: imageName), for: .normal)
        return button
    }

    class func makeSaveButton() -> UIButton {
        makeButtonWithString(label: "Save")
    }

    class func makeDiscardButton() -> UIButton {
        makeButtonWithString(label: "Discard")
    }

    class func makeButtonWithString(label: String) -> UIButton {
        let button = UIButton()
        button.setTitle(label, for: .normal)
        button.setTitleColor(UIColor.blue, for: .normal)
        return button
    }

    class func makeConflictIndexButton(conflictIdx: Int) -> UIButton {
        let button = UIButton()
        button.setTitle(String(conflictIdx), for: .normal)
        button.setTitleColor(UIColor.red, for: .normal)
        return button
    }
}
