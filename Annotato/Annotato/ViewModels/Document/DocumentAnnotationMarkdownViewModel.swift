import UIKit

class DocumentAnnotationMarkdownViewModel: DocumentAnnotationTextViewModel {
    init(id: UUID, content: String, height: Double) {
        super.init(id: id, content: content, height: height, annotationType: .markdown)
    }

    override func toView<T>(in parentView: T) -> DocumentAnnotationSectionView where T: UIView {
        let frame = CGRect(x: .zero, y: .zero, width: parentView.frame.width, height: height)
        let view = DocumentAnnotationMarkdownView(
            frame: frame,
            textContainer: nil,
            viewModel: self
        )
        view.text = content
        view.actionDelegate = parentView as? DocumentAnnotationView
        return view
    }
}
