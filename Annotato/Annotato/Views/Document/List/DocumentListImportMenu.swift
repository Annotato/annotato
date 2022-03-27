import UIKit

class DocumentListImportMenu: UIStackView {
    weak var actionDelegate: DocumentListImportMenuDelegate?
    private let buttonHeight = 30.0

    @available(*, unavailable)
    required init(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override init(frame: CGRect) {
        super.init(frame: frame)
        self.axis = .vertical

        self.backgroundColor = UIColor.systemGray6
        self.layer.cornerRadius = 15.0
        self.distribution = .fillProportionally

        initializeSubviews()
    }

    private func initializeSubviews() {
        let fromIpadButton = makeFromIpadButton()
        let divider = makeDivider()
        let fromCodeButton = makeFromCodeButton()

        self.addArrangedSubview(fromIpadButton)
        self.addArrangedSubview(divider)
        self.addArrangedSubview(fromCodeButton)

        divider.heightAnchor.constraint(equalToConstant: 0.5).isActive = true
    }

    private func makeImportMenuButton() -> UIButton {
        let button = UIButton()
        button.translatesAutoresizingMaskIntoConstraints = false
        button.configuration = .plain()
        return button
    }

    private func makeFromIpadButton() -> UIButton {
        let button = makeImportMenuButton()
        button.setTitle("From iPad", for: .normal)
        button.addTarget(self, action: #selector(didTapFromIpadButton), for: .touchUpInside)
        return button
    }

    private func makeFromCodeButton() -> UIButton {
        let button = makeImportMenuButton()
        button.setTitle("From code", for: .normal)
        button.addTarget(self, action: #selector(didTapFromCodeButton), for: .touchUpInside)
        return button
    }

    private func makeDivider() -> UIView {
        let divider = UIView()
        divider.backgroundColor = UIColor.systemGray
        return divider
    }

    @objc
    private func didTapFromIpadButton() {
        actionDelegate?.didTapFromIpadButton()
        self.isHidden = true
    }

    @objc
    private func didTapFromCodeButton() {
        actionDelegate?.didTapFromCodeButton()
        self.isHidden = true
    }
}
