import UIKit

class ToggleableButton: UIButton {
    override var isSelected: Bool {
        didSet {
            if isSelected {
                self.tintColor = .systemBlue
            } else {
                self.tintColor = .systemGray
            }
        }
    }

    @available(*, unavailable)
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override init(frame: CGRect) {
        super.init(frame: frame)
    }
}
