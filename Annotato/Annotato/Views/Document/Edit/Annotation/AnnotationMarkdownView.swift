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

        setUpPreviewView()
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
            editView.resizeFrameToFitContent()
            changeSize(to: editView.frame.size)
        } else {
            editView.removeFromSuperview()
            previewView.removeFromSuperview()
            isEditable = false
            addSubview(previewView)
            loadMarkdown()
        }
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

extension AnnotationMarkdownView: WKNavigationDelegate {
    // References: https://stackoverflow.com/questions/27850792/uiwebview-dynamic-content-size
    func webView(_ webView: WKWebView, didFinish navigation: WKNavigation!) {
        webView.frame.size = CGSize(width: frame.width, height: webView.scrollView.contentSize.height)
        webView.changeFont(fontFamilies: "-apple-system, BlinkMacSystemFont, sans-serif")
        webView.contentMode = .scaleAspectFit
        webView.sizeToFit()
        changeSize(to: webView.frame.size)
    }

    func loadMarkdown() {
        guard let payload = viewModel.content.data(using: .utf8) else {
            return
        }

        Task {
            let markdownToHtmlServiceUrl = "https://pandoc.bilimedtech.com/html"
            guard let data = try? await URLSessionHTTPService()
                    .postMarkdown(url: markdownToHtmlServiceUrl, data: payload) else {
                return
            }
            let htmlString = String(data: data, encoding: .utf8) ?? ""
            previewView.loadHTMLStringWithCorrectScale(content: htmlString, baseURL: nil)
        }
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
