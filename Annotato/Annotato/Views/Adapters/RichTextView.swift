import RichTextView
import UIKit

extension RichTextView: AnnotatoMarkdownService {
    func renderMarkdown(from input: String, frame: CGRect) -> UIView {
        let containerView = UIView(frame: frame)

        let leftPadding = 5.0
        let topPadding = 5.0
        let richTextFrame = CGRect(
            x: leftPadding,
            y: topPadding,
            width: frame.width - leftPadding * 2,
            height: frame.height - topPadding * 2
        )

        let richTextView = RichTextView(
            input: input,
            latexParser: LatexParser(),
            font: UIFont.systemFont(ofSize: UIFont.systemFontSize),
            textColor: UIColor.black,
            isSelectable: true,
            isEditable: false,
            latexTextBaselineOffset: 0,
            interactiveTextColor: UIColor.blue,
            textViewDelegate: nil,
            frame: richTextFrame,
            completion: nil
        )

        containerView.addSubview(richTextView)
        return containerView
    }
}
