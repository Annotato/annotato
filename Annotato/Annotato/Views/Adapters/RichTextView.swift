import RichTextView
import UIKit

extension RichTextView: AnnotatoMarkdownService {
    func renderMarkdown(from input: String, frame: CGRect) -> UIView {
        RichTextView(
            input: input,
            latexParser: LatexParser(),
            font: UIFont.systemFont(ofSize: UIFont.systemFontSize),
            textColor: UIColor.black,
            isSelectable: true,
            isEditable: false,
            latexTextBaselineOffset: 0,
            interactiveTextColor: UIColor.blue,
            textViewDelegate: nil,
            frame: frame,
            completion: nil
        )
    }
}
