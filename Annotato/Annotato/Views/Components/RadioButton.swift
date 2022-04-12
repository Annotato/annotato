import UIKit

class RadioButton: ImageToggleableButton {
    init() {
        let selectedImage = UIImage(systemName: SystemImageName.circleFilled.rawValue)
        let unselectedImage = UIImage(systemName: SystemImageName.circle.rawValue)
        super.init(selectedImage: selectedImage, unselectedImage: unselectedImage)
    }
}
