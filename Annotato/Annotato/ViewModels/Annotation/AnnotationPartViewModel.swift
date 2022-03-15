import CoreGraphics
import Foundation

protocol AnnotationPartViewModel: AnyObject {
    var parentViewModel: AnnotationViewModel? { get set }
    var id: UUID { get }
    var origin: CGPoint { get }
    var width: Double { get }
    var height: Double { get set }
    var isEmpty: Bool { get }
    func toView() -> AnnotationPartView
    func enterEditMode()
    func enterViewMode()
    func remove()
}

extension AnnotationPartViewModel {
    var size: CGSize {
        CGSize(width: width, height: height)
    }

    var frame: CGRect {
        CGRect(origin: origin, size: size)
    }

    func setHeight(to newHeight: Double) {
        self.height = newHeight
        parentViewModel?.resize()
    }

    func didSelect() {
        parentViewModel?.setSelectedPart(to: self)
    }
}
