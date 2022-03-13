import UIKit

class DocumentListToolbarView: UIToolbar {
    weak var actionDelegate: DocumentListToolbarDelegate?

    @available(*, unavailable)
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override init(frame: CGRect) {
        super.init(frame: frame)

        let flexibleSpace = makeFlexibleSpace()
        let addButton = makeAddButton()
        self.items = [flexibleSpace, addButton]
    }

    private func makeAddButton() -> UIBarButtonItem {
        UIBarButtonItem(barButtonSystemItem: .add, target: self, action: #selector(didTapAddButton))
    }

    @objc
    private func didTapAddButton() {
        actionDelegate?.didTapAddButton()
    }
}
