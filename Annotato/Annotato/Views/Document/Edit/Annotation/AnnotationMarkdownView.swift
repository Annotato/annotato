import UIKit
import Combine

class AnnotationMarkdownView: UIView, AnnotationPartView {
    private(set) var viewModel: AnnotationMarkdownViewModel
    private(set) var editView: UITextView
    private var cancellables: Set<AnyCancellable> = []
    private var heightConstraint = NSLayoutConstraint()

    @available(*, unavailable)
    required init(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    init(viewModel: AnnotationMarkdownViewModel) {
        self.viewModel = viewModel
        self.editView = UITextView(frame: viewModel.editFrame)
        super.init(frame: viewModel.frame)

        switchView(basedOn: viewModel.isEditing)
        setUpEditView()
        setUpSubscriber()
        setUpStyle()
    }

    private func setUpEditView() {
        editView.isScrollEnabled = false
        editView.delegate = self
    }

    private func setUpStyle() {
        heightConstraint = self.heightAnchor.constraint(equalToConstant: self.frame.height)
        self.heightConstraint.isActive = true
        self.layer.borderWidth = 1.0
        self.layer.borderColor = UIColor.lightGray.cgColor
    }

    private func switchView(basedOn isEditing: Bool) {
        if isEditing {
            editView.text = viewModel.content
            addSubview(editView)
        } else {
            editView.removeFromSuperview()
        }
    }

    private func setUpSubscriber() {
        viewModel.$isEditing.sink(receiveValue: { [weak self] isEditing in
            self?.switchView(basedOn: isEditing)
        }).store(in: &cancellables)
    }
}

extension AnnotationMarkdownView: UITextViewDelegate {
    func textViewDidChange(_ textView: UITextView) {
        guard let text = editView.text else {
            return
        }
        editView.resizeFrameToFitContent()
        self.frame.size = editView.frame.size
        self.heightConstraint.constant = self.frame.height
        viewModel.setContent(to: text)
        viewModel.setHeight(to: frame.height)
    }
}
