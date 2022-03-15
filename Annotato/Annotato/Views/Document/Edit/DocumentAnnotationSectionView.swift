import UIKit
import AnnotatoSharedLibrary

protocol DocumentAnnotationSectionView where Self: UIView {
    var annotationType: AnnotationType { get }
    var isEmpty: Bool { get }
    func enterEditMode()
    func enterViewMode()
}
