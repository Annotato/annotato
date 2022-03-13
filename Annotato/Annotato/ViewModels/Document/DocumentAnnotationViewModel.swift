import CoreGraphics

class DocumentAnnotationViewModel {
    private(set) var center: CGPoint
    private(set) var parts: [DocumentAnnotationPartViewModel]
    private(set) var width: Double

    init(center: CGPoint, width: Double, parts: [DocumentAnnotationPartViewModel]) {
        self.center = center
        self.width = width
        self.parts = parts

        if self.parts.isEmpty {
            self.parts.append(DocumentAnnotationTextViewModel(
                content: "", height: 50.0, annotationType: .plainText))
        }
    }

    var height: Double {
        self.parts.reduce(0, {accHeight, nextPart in
            accHeight + nextPart.height
        })
    }

    var isNew: Bool {
        self.parts.count == 1 && self.parts[0].content.isEmpty
    }

    var startingAnnotationType: AnnotationType? {
        isNew ? self.parts[0].annotationType : nil
    }
}
