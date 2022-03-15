import UIKit
import AnnotatoSharedLibrary

protocol DocumentAnnotationPartViewModel {
    var isEmpty: Bool { get }
    var annotationType: AnnotationType { get }
    var content: String { get }
    var height: Double { get }
    func toView<T: UIView>(in parentView: T) -> DocumentAnnotationSectionView
}
