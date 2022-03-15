import UIKit
import Combine

class AnnotationMarkdownView: UIView, AnnotationPartView {
    private(set) var viewModel: AnnotationMarkdownViewModel
    private(set) var editView: UITextView
    private var cancellables: Set<AnyCancellable> = []

    @available(*, unavailable)
    required init(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    init(viewModel: AnnotationMarkdownViewModel) {
        self.viewModel = viewModel
        self.editView = UITextView(frame: viewModel.editFrame)
        super.init(frame: viewModel.frame)
        switchView(basedOn: viewModel.isEditing)
        setUpSubscriber()
        self.heightAnchor.constraint(equalToConstant: self.frame.height).isActive = true
        self.layer.borderWidth = 1.0
        self.layer.borderColor = UIColor.systemGray.cgColor
    }

    private func setUpEditView() {
        editView.isScrollEnabled = false
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
