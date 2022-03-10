import UIKit

class DocumentListToolbarView: UIToolbar {
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

    private func makeFlexibleSpace() -> UIBarButtonItem {
        UIBarButtonItem(barButtonSystemItem: .flexibleSpace, target: self, action: nil)
    }

    private func makeAddButton() -> UIBarButtonItem {
        UIBarButtonItem(barButtonSystemItem: .add, target: self, action: #selector(didTapAddButton))
    }

    @objc
    private func didTapAddButton() {
        print("tapped add button")
    }
}
