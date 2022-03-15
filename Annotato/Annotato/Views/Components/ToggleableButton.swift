import UIKit

class ToggleableButton: UIButton {
    weak var delegate: ToggleableButtonDelegate?

    @available(*, unavailable)
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override init(frame: CGRect) {
        super.init(frame: frame)

        addTarget(self, action: #selector(didTap), for: .touchUpInside)
    }

    @objc
    private func didTap() {
        select()
    }

    func select() {
        isSelected = true
        self.tintColor = .systemBlue
        delegate?.didSelect(button: self)
    }

    func unselect() {
        isSelected = false
        self.tintColor = .systemGray
    }
}
