import CoreGraphics
import UIKit

class DocumentAnnotationTextViewModel: DocumentAnnotationPartViewModel {
    private(set) var annotationType: AnnotationType
    private(set) var content: String
    private(set) var height: Double

    var isEmpty: Bool {
        content.isEmpty
    }

    init(content: String, height: Double, annotationType: AnnotationType = .plainText) {
        self.annotationType = annotationType
        self.content = content
        self.height = height
    }

    func toView<T>(in parentView: T) -> DocumentAnnotationSectionView where T: UIView {
        let frame = CGRect(x: .zero, y: .zero, width: parentView.frame.width, height: height)
        let view = DocumentAnnotationTextView(frame: frame, textContainer: nil)
        view.text = content
        view.delegate = parentView as? DocumentAnnotationView
        return view
    }
}
