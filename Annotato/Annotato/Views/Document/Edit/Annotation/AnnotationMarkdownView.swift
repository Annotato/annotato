import UIKit

class AnnotationMarkdownView: UIView, AnnotationPartView {
    private(set) var viewModel: AnnotationMarkdownViewModel
    private(set) var editView: UITextView

    @available(*, unavailable)
    required init(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    init(viewModel: AnnotationMarkdownViewModel) {
        self.viewModel = viewModel
        self.editView = UITextView(frame: viewModel.editFrame)
        super.init(frame: viewModel.frame)
        initializeSubviews()
    }

    func initializeSubviews() {
        if viewModel.isEditing {
            addSubview(editView)
        } else {
            editView.removeFromSuperview()
        }
    }
}
