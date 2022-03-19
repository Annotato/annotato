import UIKit
import Combine
import WebKit

class AnnotationMarkdownView: UIView, AnnotationPartView {
    private(set) var viewModel: AnnotationMarkdownViewModel
    private(set) var editView: UITextView
    private(set) var previewView: WKWebView
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
        self.previewView = WKWebView()
        self.isEditable = false
        super.init(frame: viewModel.frame)

        switchView(basedOn: viewModel.isEditing)
        setUpEditView()
        setUpPreviewView()
        setUpSubscribers()
        setUpStyle()
        addGestureRecognizers()
    }

    private func setUpEditView() {
        editView.isScrollEnabled = false
        editView.delegate = self
    }

    private func setUpPreviewView() {
        previewView.navigationDelegate = self
    }

    private func setUpStyle() {
        heightConstraint = self.heightAnchor.constraint(equalToConstant: self.frame.height)
        self.heightConstraint.isActive = true
        self.layer.borderWidth = 0.3
        self.layer.borderColor = UIColor.lightGray.cgColor
    }

    private func switchView(basedOn isEditing: Bool) {
        if isEditing {
            editView.removeFromSuperview()
            previewView.removeFromSuperview()
            isEditable = true
            editView.text = viewModel.content
            addSubview(editView)
        } else {
            editView.removeFromSuperview()
            previewView.removeFromSuperview()
            isEditable = false
            guard let url = URL(string: "https://www.apple.com") else {
                return
            }
            previewView.load(URLRequest(url: url))
            addSubview(previewView)
        }
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
        self.frame.size = editView.frame.size
        self.heightConstraint.constant = self.frame.height
        viewModel.setContent(to: text)
        viewModel.setHeight(to: frame.height)
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

extension AnnotationMarkdownView: WKNavigationDelegate {
    func webView(_ webView: WKWebView, didFinish navigation: WKNavigation!) {
        webView.frame.size = CGSize(width: frame.width, height: webView.scrollView.contentSize.height)
        webView.contentMode = .scaleAspectFit
        self.frame.size = webView.frame.size
        self.heightConstraint.constant = self.frame.height
        viewModel.setHeight(to: frame.height)
    }
}
