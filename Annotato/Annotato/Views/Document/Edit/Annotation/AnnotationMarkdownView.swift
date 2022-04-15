import UIKit
import Combine
import WebKit

class AnnotationMarkdownView: UIView, AnnotationPartView {
    private(set) var presenter: AnnotationMarkdownPresenter
    private(set) var editView: UITextView
    private(set) var previewView: UIView
    private var cancellables: Set<AnyCancellable> = []
    private var heightConstraint = NSLayoutConstraint()
    private var isEditable: Bool

    @available(*, unavailable)
    required init(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    init(presenter: AnnotationMarkdownPresenter) {
        self.presenter = presenter
        self.editView = UITextView(frame: presenter.editFrame)
        self.previewView = UIView()
        self.isEditable = false
        super.init(frame: presenter.frame)

        setUpEditView()
        setUpStyle()
        setUpSubscribers()
        addGestureRecognizers()
        switchView(basedOn: presenter.isEditing)
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
            editView.text = presenter.content
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
            .renderMarkdown(from: presenter.content, frame: markdownFrame)
        markdownView.backgroundColor = .white

        return markdownView
    }

    private func changeSize(to size: CGSize) {
        self.frame.size = size
        self.heightConstraint.constant = self.frame.height
        presenter.setHeight(to: size.height)
    }

    private func setUpSubscribers() {
        presenter.$isEditing.sink(receiveValue: { [weak self] isEditing in
            DispatchQueue.main.async {
                self?.switchView(basedOn: isEditing)
            }
        }).store(in: &cancellables)

        presenter.$isRemoved.sink(receiveValue: { [weak self] isRemoved in
            if isRemoved {
                DispatchQueue.main.async {
                    self?.removeFromSuperview()
                }
            }
        }).store(in: &cancellables)

        presenter.$isSelected.sink(receiveValue: { [weak self] isSelected in
            if isSelected {
                DispatchQueue.main.async {
                    self?.editView.becomeFirstResponder()
                    self?.editView.showSelected()
                }
            } else {
                DispatchQueue.main.async {
                    self?.editView.resignFirstResponder()
                }
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
        presenter.setContent(to: text)
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
            presenter.didSelect()
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
