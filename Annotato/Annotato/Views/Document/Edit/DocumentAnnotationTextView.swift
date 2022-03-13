import UIKit

class DocumentAnnotationTextView: UITextView {
    @available(*, unavailable)
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override init(frame: CGRect, textContainer: NSTextContainer?) {
        super.init(frame: frame, textContainer: textContainer)

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
