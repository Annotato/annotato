import UIKit
import Combine
import WebKit

class AnnotationMarkdownView: UIView, AnnotationPartView {
    private(set) var viewModel: AnnotationMarkdownViewModel
    private(set) var editView: UITextView
    private(set) var previewView: UIView
    private var cancellables: Set<AnyCancellable> = []
    private var heightConstraint = NSLayoutConstraint()
    private var isEditable: Bool

    @available(*, unavailable)
    required init(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    init(viewModel: AnnotationMarkdownViewModel) {
        self.viewModel = viewModel
        self.editView = UITextView(frame: viewModel.editFrame)
        self.previewView = UIView()
        self.isEditable = false
        super.init(frame: viewModel.frame)

        setUpEditView()
        setUpStyle()
        setUpSubscribers()
        addGestureRecognizers()
        switchView(basedOn: viewModel.isEditing)
    }

    private func setUpEditView() {
        editView.isScrollEnabled = false
        editView.delegate = self
    }

    private func setUpStyle() {
        heightConstraint = self.heightAnchor.constraint(equalToConstant: self.frame.height)
        self.heightConstraint.isActive = true
        self.addAnnotationPartBorders()
    }

    private func switchView(basedOn isEditing: Bool) {
        editView.removeFromSuperview()
        previewView.removeFromSuperview()

        if isEditing {
            isEditable = true
            editView.text = viewModel.content
            addSubview(editView)
            editView.resizeFrameToFitContent()
            changeSize(to: editView.frame.size)
        } else {
            isEditable = false
            previewView = makeMarkdownView()
            addSubview(previewView)
            changeSize(to: previewView.frame.size)
        }
    }

    private func makeMarkdownView() -> UIView {
        let markdownFrame = CGRect(
            x: .zero,
            y: .zero,
            width: editView.frame.width,
            height: editView.frame.height * 1.5
        )

        let markdownView = AnnotatoMarkdown()
            .renderMarkdown(from: viewModel.content, frame: markdownFrame)
        markdownView.backgroundColor = .white

        return markdownView
    }

    private func changeSize(to size: CGSize) {
        self.frame.size = size
        self.heightConstraint.constant = self.frame.height
        viewModel.setHeight(to: size.height)
    }

    private func setUpSubscribers() {
        viewModel.$isEditing.sink(receiveValue: { [weak self] isEditing in
            self?.switchView(basedOn: isEditing)
        }).store(in: &cancellables)

        viewModel.$isRemoved.sink(receiveValue: { [weak self] isRemoved in
            if isRemoved {
                self?.removeFromSuperview()
            }
        }).store(in: &cancellables)

        viewModel.$isSelected.sink(receiveValue: { [weak self] isSelected in
            if isSelected {
                self?.editView.becomeFirstResponder()
                self?.editView.showSelected()
            } else {
                self?.editView.resignFirstResponder()
            }
        }).store(in: &cancellables)
    }
}

extension AnnotationMarkdownView: UITextViewDelegate {
    func textViewDidChange(_ textView: UITextView) {
        guard let text = editView.text else {
            return
        }
        editView.resizeFrameToFitContent()
        viewModel.setContent(to: text)
        changeSize(to: editView.frame.size)
    }
}

// MARK: Gestures
 extension AnnotationMarkdownView {
    private func addGestureRecognizers() {
        let tapGestureRecognizer = UITapGestureRecognizer(
            target: self, action: #selector(didTap))
        addGestureRecognizer(tapGestureRecognizer)
        let editViewTapGestureRecognizer = UITapGestureRecognizer(
            target: self, action: #selector(didTap))
        editViewTapGestureRecognizer.delegate = self
        editView.addGestureRecognizer(editViewTapGestureRecognizer)
    }

    @objc
    private func didTap() {
        if isEditable {
            viewModel.didSelect()
        }
    }
 }

extension AnnotationMarkdownView: UIGestureRecognizerDelegate {
    func gestureRecognizer(
        _ gestureRecognizer: UIGestureRecognizer,
        shouldRecognizeSimultaneouslyWith otherGestureRecognizer: UIGestureRecognizer
    ) -> Bool {
        true
    }
}
