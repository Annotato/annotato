import UIKit

protocol AnnotationPartView where Self: UIView {
}

extension AnnotationPartView {
    func addAnnotationPartBorders() {
        self.layer.borderWidth = 0.3
        self.layer.borderColor = UIColor.lightGray.cgColor
    }
}
