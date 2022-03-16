import UIKit

class DocumentListToolbarView: UIToolbar {
    weak var actionDelegate: DocumentListToolbarDelegate?

    @available(*, unavailable)
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override init(frame: CGRect) {
        super.init(frame: frame)

        let importFileButton = makeImportFileButton()
        self.items = [flexibleSpace, importFileButton]
    }

    private func makeImportFileButton() -> UIBarButtonItem {
        UIBarButtonItem(barButtonSystemItem: .action, target: self, action: #selector(didTapImportFileButton))
    }

    @objc
    private func didTapImportFileButton() {
        actionDelegate?.didTapImportFileButton()
    }
}
