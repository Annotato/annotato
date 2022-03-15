// import UIKit
//
// class DocumentAnnotationMarkdownView: DocumentAnnotationTextView {
//    private var markdownView: UIView?
//    let frameHeightMultiplier: Double = 2
//
//    init(
//        frame: CGRect,
//        textContainer: NSTextContainer?,
//        viewModel: DocumentAnnotationMarkdownViewModel
//    ) {
//        super.init(frame: frame, textContainer: textContainer, viewModel: viewModel)
//    }
//
//    override func enterEditMode() {
//        isEditable = true
//
//        guard let markdownView = markdownView else {
//            return
//        }
//        markdownView.removeFromSuperview()
//    }
//
//    override func enterViewMode() {
//        isEditable = false
//
//        let annotatoMarkdown = AnnotatoMarkdown()
//        let widthOffset = 5.0
//        let heightOffset = textContainerInset.top
//        let markdownFrame = CGRect(
//            origin: CGPoint(x: widthOffset, y: heightOffset),
//            size: CGSize(
//                width: self.frame.width - widthOffset * 2,
//                height: self.frame.height - heightOffset * 2
//            )
//        )
//        let markdownView = annotatoMarkdown.renderMarkdown(from: text, frame: markdownFrame)
//        markdownView.backgroundColor = UIColor.white
//
//        self.addSubview(markdownView)
//        self.markdownView = markdownView
//    }
// }
