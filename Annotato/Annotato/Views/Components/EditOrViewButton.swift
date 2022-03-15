import UIKit

class EditOrViewButton: UIButton {
    weak var delegate: EditOrViewButtonDelegate?

    override var isSelected: Bool {
        didSet {
            setImage()
            delegate?.changeMode()
        }
    }

    @available(*, unavailable)
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    init(isEditing: Bool) {
        super.init(frame: .zero)
        setImage()
        addTarget(self, action: #selector(didTap), for: .touchUpInside)
    }

    private func setImage() {
        let imageName = isSelected ? "eye" : "pencil"
        setImage(UIImage(systemName: imageName), for: .normal)
    }

    @objc
    private func didTap() {
        isSelected.toggle()
    }

    func select() {
        isSelected = true
    }

    func unselect() {
        isSelected = false
    }
}
