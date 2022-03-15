import UIKit
import Combine

class AnnotationTextView: UITextView, AnnotationPartView {
    private(set) var viewModel: AnnotationTextViewModel
    private var cancellables: Set<AnyCancellable> = []

    @available(*, unavailable)
    required init(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    init(viewModel: AnnotationTextViewModel) {
        self.viewModel = viewModel
        super.init(frame: viewModel.frame, textContainer: nil)
        self.text = viewModel.content
        self.isEditable = viewModel.isEditing
        self.isScrollEnabled = false
        self.delegate = self
        setUpSubscriber()
        self.layer.borderWidth = 1.0
        self.layer.borderColor = UIColor.lightGray.cgColor
    }

    private func setUpSubscriber() {
        viewModel.$isEditing.sink(receiveValue: { [weak self] isEditing in
            self?.isEditable = isEditing
        }).store(in: &cancellables)
    }
}

extension AnnotationTextView: UITextViewDelegate {
    func textViewDidChange(_ textView: UITextView) {
        guard let text = self.text else {
            return
        }

        resizeFrameToFitContent()
        viewModel.setContent(to: text)
        viewModel.setHeight(to: frame.height)
    }
}
