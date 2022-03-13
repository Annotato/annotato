import RichTextView

class AnnotatoMarkdown {
    private var markdownService: AnnotatoMarkdownService

    init() {
        markdownService = RichTextView(frame: .zero)
    }

    func renderMarkdown(from input: String, frame: CGRect) -> UIView {
        markdownService.renderMarkdown(from: input, frame: frame)
    }
}
