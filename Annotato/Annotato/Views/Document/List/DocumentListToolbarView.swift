import UIKit

class DocumentListToolbarView: UIToolbar {
    weak var actionDelegate: DocumentListToolbarDelegate?

    @available(*, unavailable)
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override init(frame: CGRect) {
        super.init(frame: frame)

        let addButton = makeAddButton()
        let importFileButton = makeImportFileButton()
        self.items = [flexibleSpace, addButton, importFileButton]
    }

    private func makeAddButton() -> UIBarButtonItem {
        UIBarButtonItem(barButtonSystemItem: .add, target: self, action: #selector(didTapAddButton))
    }

    private func makeImportFileButton() -> UIBarButtonItem {
        UIBarButtonItem(barButtonSystemItem: .search, target: self, action: #selector(didTapImportFileButton))
    }

    @objc
    private func didTapAddButton() {
        actionDelegate?.didTapAddButton()
    }

    @objc
    private func didTapImportFileButton() {
        actionDelegate?.didTapImportFileButton()
    }
}
