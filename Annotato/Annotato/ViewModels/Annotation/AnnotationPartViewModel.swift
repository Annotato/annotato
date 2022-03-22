import CoreGraphics
import Foundation
import AnnotatoSharedLibrary

protocol AnnotationPartViewModel: AnyObject {
    var parentViewModel: AnnotationViewModel? { get set }
    var model: AnnotationPart { get }
    var id: UUID { get }
    var origin: CGPoint { get }
    var width: Double { get }
    var height: Double { get }
    var isSelected: Bool { get set }

    func toView() -> AnnotationPartView
    func enterEditMode()
    func enterViewMode()
}

extension AnnotationPartViewModel {
    var size: CGSize {
        CGSize(width: width, height: height)
    }

    var frame: CGRect {
        CGRect(origin: origin, size: size)
    }

    func setHeight(to newHeight: Double) {
        model.setHeight(to: newHeight)
        parentViewModel?.resize()
    }

    func didSelect() {
        parentViewModel?.setSelectedPart(to: self)
    }
}
