import UIKit

protocol DocumentAnnotationPartViewModel {
    var content: String { get }
    var height: Double { get }
    func toView<T: UIView>(in parentView: T) -> DocumentAnnotationSectionView
}
