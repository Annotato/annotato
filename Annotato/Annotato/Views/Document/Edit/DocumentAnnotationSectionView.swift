import UIKit

protocol DocumentAnnotationSectionView where Self: UIView {
    var annotationType: AnnotationType { get }
    var partViewModel: DocumentAnnotationPartViewModel { get }
    var isEmpty: Bool { get }
    func enterEditMode()
    func enterViewMode()
    func showSelected()
}

extension DocumentAnnotationSectionView {
    func showSelected() {
        let oldColor = backgroundColor
        let duration = 0.2
        let red: CGFloat = 245 / 255
        let green: CGFloat = 234 / 255
        let blue: CGFloat = 105 / 255
        let alpha: CGFloat = 0.3
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
}
