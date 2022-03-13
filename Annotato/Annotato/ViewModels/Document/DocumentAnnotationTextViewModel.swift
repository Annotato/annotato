import CoreGraphics
import UIKit

class DocumentAnnotationTextViewModel: DocumentAnnotationPartViewModel {
    private(set) var content: String
    private(set) var height: Double

    init(content: String, height: Double) {
        self.content = content
        self.height = height
    }

    func toView<T>(in parentView: T) -> UIView where T: UIView {
        let frame = CGRect(x: .zero, y: .zero, width: parentView.frame.width, height: height)
        let view = DocumentAnnotationTextView(frame: frame)
        view.text = content
        view.delegate = parentView as? DocumentAnnotationView
        return view
    }
}
