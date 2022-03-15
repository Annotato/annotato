import UIKit

class AnnotationTextView: UITextView, AnnotationPartView {
    private(set) var viewModel: AnnotationTextViewModel

    @available(*, unavailable)
    required init(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    init(viewModel: AnnotationTextViewModel) {
        self.viewModel = viewModel
        super.init(frame: viewModel.frame, textContainer: nil)
        self.text = viewModel.content
    }
}
