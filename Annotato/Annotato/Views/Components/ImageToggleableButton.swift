import UIKit

class ImageToggleableButton: UIButton {
    let selectedImage: UIImage
    let unselectedImage: UIImage

    @available(*, unavailable)
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override var isSelected: Bool {
        didSet {
            setImage()
        }
    }

    init(selectedImage: UIImage?, unselectedImage: UIImage?) {
        self.selectedImage = selectedImage ?? UIImage()
        self.unselectedImage = unselectedImage ?? UIImage()
        super.init(frame: .zero)
        setImage()
    }

    private func setImage() {
        let image = isSelected ? selectedImage : unselectedImage
        setImage(image, for: .normal)
    }
}
