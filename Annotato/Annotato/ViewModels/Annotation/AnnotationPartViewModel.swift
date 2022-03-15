import CoreGraphics

protocol AnnotationPartViewModel: AnyObject {
    var parentViewModel: AnnotationViewModel? { get set }
    var origin: CGPoint { get }
    var width: Double { get }
    var height: Double { get set }
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
        self.height = newHeight
        parentViewModel?.resize()
    }
}
