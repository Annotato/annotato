import UIKit

class DocumentEditToolbarView: UIToolbar {
    weak var actionDelegate: DocumentEditToolbarDelegate?

    @available(*, unavailable)
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override init(frame: CGRect) {
        super.init(frame: frame)

        let backButton = makeBackButton()
        let flexibleSpace = makeFlexibleSpace()
        self.items = [backButton, flexibleSpace]
    }

    private func makeBackButton() -> UIBarButtonItem {
        UIBarButtonItem(title: "Back", style: .plain, target: self, action: #selector(didTapBackButton))
    }

    @objc
    private func didTapBackButton() {
        actionDelegate?.didTapBackButton()
    }
}
