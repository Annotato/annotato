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

    func hasExceededBounds(bounds: CGRect) -> Bool {
        let hasExceededTop = frame.minY < bounds.minY
        let hasExceededBottom = frame.maxY > bounds.maxY
        let hasExceededLeft = frame.minX < bounds.minX
        let hasExceededRight = frame.maxX > bounds.maxX
        if hasExceededTop || hasExceededBottom || hasExceededLeft || hasExceededRight {
            return true
        }
        return false
    }
}
