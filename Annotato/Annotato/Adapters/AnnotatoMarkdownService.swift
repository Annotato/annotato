import UIKit

protocol AnnotatoMarkdownService {
    func renderMarkdown(from input: String, frame: CGRect) -> UIView
}
