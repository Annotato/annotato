import UIKit

class EditOrViewButton: UIButton {
    @available(*, unavailable)
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override var isSelected: Bool {
        didSet {
            setImage()
        }
    }

    init(isEditing: Bool) {
        super.init(frame: .zero)
        setImage()
    }

    private func setImage() {
        let imageName = isSelected ? "eye" : "pencil"
        setImage(UIImage(systemName: imageName), for: .normal)
    }
}
