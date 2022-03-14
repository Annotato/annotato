import UIKit

class DocumentAnnotationTextView: UITextView, DocumentAnnotationSectionView {
    weak var actionDelegate: DocumentAnnotationSectionDelegate?
    private(set) var viewModel: DocumentAnnotationTextViewModel
    var partViewModel: DocumentAnnotationPartViewModel {
        viewModel
    }

    var annotationType: AnnotationType {
        viewModel.annotationType
    }

    var isEmpty: Bool {
        text.isEmpty
    }

    @available(*, unavailable)
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    init(
        frame: CGRect,
        textContainer: NSTextContainer?,
        viewModel: DocumentAnnotationTextViewModel
    ) {
        self.viewModel = viewModel
        super.init(frame: frame, textContainer: textContainer)

        delegate = self
        translatesAutoresizingMaskIntoConstraints = false
        isScrollEnabled = false
        addTapGestureRecognizer()
    }

    func enterEditMode() {
        isEditable = true
    }

    func enterViewMode() {
        isEditable = false
    }

    private func addTapGestureRecognizer() {
        let gestureRecognizer = UITapGestureRecognizer(
            target: self, action: #selector(didTap)
        )
        gestureRecognizer.delegate = self
        addGestureRecognizer(gestureRecognizer)
    }

    @objc private func didTap() {
        if isEditable {
            showSelected()
            actionDelegate?.didSelect(section: self)
        }
    }
}

extension DocumentAnnotationTextView: UIGestureRecognizerDelegate {
    func gestureRecognizer(
        _ gestureRecognizer: UIGestureRecognizer,
        shouldRecognizeSimultaneouslyWith otherGestureRecognizer: UIGestureRecognizer
    ) -> Bool {
        true
    }
}

extension DocumentAnnotationTextView: UITextViewDelegate {
    func textViewDidChange(_ textView: UITextView) {
        let fixedWidth = frame.size.width
        let newSize = sizeThatFits(CGSize(width: fixedWidth, height: CGFloat.greatestFiniteMagnitude))
        frame.size = CGSize(width: max(newSize.width, fixedWidth), height: newSize.height)

        viewModel.setContent(to: text)
        viewModel.setHeight(to: frame.size.height)
        actionDelegate?.frameDidChange()
    }

    func textViewDidBeginEditing(_ textView: UITextView) {
        actionDelegate?.didBeginEditing(annotationType: annotationType)
    }

    func textViewDidEndEditing(_ textView: UITextView) {
        if isEmpty {
            actionDelegate?.didBecomeEmpty(section: self)
        }
    }
}
