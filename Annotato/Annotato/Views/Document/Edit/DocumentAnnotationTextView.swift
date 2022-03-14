import UIKit

class DocumentAnnotationTextView: UITextView, DocumentAnnotationSectionView {
    weak var actionDelegate: DocumentAnnotationSectionDelegate?
    private(set) var viewModel: DocumentAnnotationTextViewModel

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

        self.layer.borderColor = UIColor.black.cgColor
        self.layer.borderWidth = 2.0
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
            actionDelegate?.didSelect(section: self)
        }
    }

    @objc private func didEdit() {
        if isEmpty {
            actionDelegate?.didBecomeEmpty(section: self)
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
