import CoreGraphics
import Foundation

class DocumentAnnotationViewModel {
    private(set) var center: CGPoint
    private(set) var parts: [DocumentAnnotationPartViewModel]
    private(set) var width: Double

    init(center: CGPoint, width: Double, parts: [DocumentAnnotationPartViewModel]) {
        self.center = center
        self.width = width
        self.parts = parts

        if self.parts.isEmpty {
            _ = addPart(for: .plainText)
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

    func addPart(for annotationType: AnnotationType) -> DocumentAnnotationPartViewModel {
        let newViewModel: DocumentAnnotationPartViewModel

        switch annotationType {
        case .plainText:
            newViewModel = DocumentAnnotationTextViewModel(id: UUID(), content: "", height: 50.0)
        case .markdown:
            newViewModel = DocumentAnnotationMarkdownViewModel(id: UUID(), content: "", height: 50.0)
        }
        parts.append(newViewModel)

        return newViewModel
    }

    func removePart(part: DocumentAnnotationPartViewModel) {
        parts.removeAll(where: { $0.id == part.id })
    }
}
