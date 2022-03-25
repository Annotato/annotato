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
        let shareButton = makeShareButton()
        self.items = [backButton, flexibleSpace, shareButton]
    }

    private func makeBackButton() -> UIBarButtonItem {
        UIBarButtonItem(title: "Back", style: .plain, target: self, action: #selector(didTapBackButton))
    }

    private func makeShareButton() -> UIBarButtonItem {
        let button = UIButton()
        button.setImage(UIImage(systemName: SystemImageName.share.rawValue), for: .normal)
        button.addTarget(self, action: #selector(didTapShareButton), for: .touchUpInside)
        return UIBarButtonItem(customView: button)
    }

    @objc
    private func didTapBackButton() {
        actionDelegate?.didTapBackButton()
    }

    @objc
    private func didTapShareButton() {
        actionDelegate?.didTapShareButton()
    }
}
