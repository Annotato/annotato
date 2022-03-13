import CoreGraphics

class DocumentAnnotationViewModel {
    private(set) var center: CGPoint
    private(set) var parts: [DocumentAnnotationPartViewModel]
    private(set) var width: Double

    init(center: CGPoint, width: Double, parts: [DocumentAnnotationPartViewModel]) {
        self.center = center
        self.width = width
        self.parts = parts
    }

    var height: Double {
        self.parts.reduce(0, {accHeight, nextPart in
            accHeight + nextPart.height
        })
    }
}
