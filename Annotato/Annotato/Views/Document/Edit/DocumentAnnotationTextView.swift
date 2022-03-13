import UIKit

class DocumentAnnotationTextView: UITextView {
    private(set) var annotationType: AnnotationType

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
        annotationType: AnnotationType = .plainText
    ) {
        self.annotationType = annotationType
        super.init(frame: frame, textContainer: textContainer)

        self.layer.borderColor = UIColor.black.cgColor
        self.layer.borderWidth = 2.0
        translatesAutoresizingMaskIntoConstraints = false
        isScrollEnabled = false
    }
}

extension DocumentAnnotationTextView: DocumentAnnotationSectionView {
    func enterEditMode() {
        isEditable = true
    }

    func enterViewMode() {
        isEditable = false
    }
}
