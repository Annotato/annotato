import CoreGraphics

protocol AnnotationPartViewModel {
    var origin: CGPoint { get }
    var width: Double { get }
    var height: Double { get }
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
}
