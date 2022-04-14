import UIKit
import Combine

class DocumentListDeleteMenu: UIStackView {
    weak var actionDelegate: DocumentListDeleteMenuDelegate?
    private let buttonHeight = 30.0
    private var cancellables: Set<AnyCancellable> = []

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
        let deleteForEveryoneButton = makeDeleteForEveryoneButton()
        let divider = makeDivider()
        let fromCodeButton = makeDeleteForSelfOnlyButton()

        self.addArrangedSubview(deleteForEveryoneButton)
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

    private func makeDeleteForEveryoneButton() -> UIButton {
        let button = makeImportMenuButton()
        button.setTitle("For all", for: .normal)
        button.addTarget(self, action: #selector(didTapDeleteForEveryoneButton), for: .touchUpInside)
        return button
    }

    private func makeDeleteForSelfOnlyButton() -> UIButton {
        let button = makeImportMenuButton()
        button.setTitle("For me only", for: .normal)
        button.addTarget(self, action: #selector(didTapDeleteForSelfOnlyButton), for: .touchUpInside)
        return button
    }

    private func makeDivider() -> UIView {
        let divider = UIView()
        divider.backgroundColor = UIColor.systemGray
        return divider
    }

    @objc
    private func didTapDeleteForEveryoneButton() {
        actionDelegate?.didTapDeleteForEveryoneButton()
        self.isHidden = true
    }

    @objc
    private func didTapDeleteForSelfOnlyButton() {
        actionDelegate?.didTapDeleteForSelfOnlyButton()
        self.isHidden = true
    }
}
