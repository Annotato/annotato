import UIKit

protocol DocumentAnnotationSectionView where Self: UIView {
    var annotationType: AnnotationType { get }
    var isEmpty: Bool { get }
    func enterEditMode()
    func enterViewMode()
}
