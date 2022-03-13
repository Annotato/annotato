import UIKit

class DocumentAnnotationMarkdownView: DocumentAnnotationTextView {
    init(frame: CGRect, textContainer: NSTextContainer?) {
        super.init(frame: frame, textContainer: textContainer, annotationType: .markdown)
    }
}
