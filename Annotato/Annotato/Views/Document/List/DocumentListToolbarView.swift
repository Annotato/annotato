import UIKit

class DocumentListToolbarView: UIToolbar {
    weak var actionDelegate: DocumentListToolbarDelegate?
    private var exitDeleteModeButton = UIBarButtonItem()

    @available(*, unavailable)
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override init(frame: CGRect) {
        super.init(frame: frame)

        let logOutButton = makeLogOutButton()
        let importFileButton = makeImportFileButton()
        exitDeleteModeButton = makeExitDeleteModeButton()
        exitDeleteMode()
        self.items = [logOutButton, flexibleSpace, exitDeleteModeButton, spaceBetween, importFileButton]
    }

    private func makeLogOutButton() -> UIBarButtonItem {
        UIBarButtonItem(title: "Log Out", style: .plain, target: self, action: #selector(didTapLogOutButton))
    }

    private func makeImportFileButton() -> UIBarButtonItem {
        UIBarButtonItem(barButtonSystemItem: .action, target: self, action: #selector(didTapImportFileButton))
    }

    private func makeExitDeleteModeButton() -> UIBarButtonItem {
        let button = UIButton()
        button.setTitle("Exit Delete Mode", for: .normal)
        button.configuration = .tinted()
        button.addTarget(self, action: #selector(didTapExitDeleteModeButton), for: .touchUpInside)

        return UIBarButtonItem(customView: button)
    }

    @objc
    private func didTapLogOutButton() {
        actionDelegate?.didTapLogOutButton()
    }

    @objc
    private func didTapImportFileButton() {
        actionDelegate?.didTapImportFileButton()
    }

    @objc
    private func didTapExitDeleteModeButton() {
        actionDelegate?.didTapExitDeleteModeButton()
    }

    func enterDeleteMode() {
        exitDeleteModeButton.customView?.isHidden = false
    }

    func exitDeleteMode() {
        exitDeleteModeButton.customView?.isHidden = true
    }
}
