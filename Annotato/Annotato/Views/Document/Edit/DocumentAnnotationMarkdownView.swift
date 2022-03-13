import UIKit

class DocumentAnnotationMarkdownView: DocumentAnnotationTextView {
    private var markdownView: UIView?
    let frameHeightMultiplier: Double = 2

    init(frame: CGRect, textContainer: NSTextContainer?) {
        super.init(frame: frame, textContainer: textContainer, annotationType: .markdown)
    }

    override func enterEditMode() {
        isEditable = true

        guard let markdownView = markdownView else {
            return
        }
        markdownView.removeFromSuperview()
    }

    override func enterViewMode() {
        isEditable = false

        let annotatoMarkdown = AnnotatoMarkdown()
        let markdownFrame = CGRect(
            origin: .zero,
            size: self.frame.size
        )
        let markdownView = annotatoMarkdown.renderMarkdown(from: text, frame: markdownFrame)
        markdownView.backgroundColor = UIColor.white

        self.addSubview(markdownView)
        self.markdownView = markdownView
    }
}
