import UIKit

class DocumentListToolbarView: UIToolbar {
    weak var actionDelegate: DocumentListToolbarDelegate?

    @available(*, unavailable)
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override init(frame: CGRect) {
        super.init(frame: frame)

        let logOutButton = makeLogOutButton()
        let importFileButton = makeImportFileButton()
        self.items = [logOutButton, flexibleSpace, importFileButton]
    }

    private func makeLogOutButton() -> UIBarButtonItem {
        UIBarButtonItem(title: "Log Out", style: .plain, target: self, action: #selector(didTapLogOutButton))
    }

    private func makeImportFileButton() -> UIBarButtonItem {
        UIBarButtonItem(barButtonSystemItem: .action, target: self, action: #selector(didTapImportFileButton))
    }

    @objc
    private func didTapLogOutButton() {
        actionDelegate?.didTapLogOutButton()
    }

    @objc
    private func didTapImportFileButton() {
        actionDelegate?.didTapImportFileButton()
    }
}
