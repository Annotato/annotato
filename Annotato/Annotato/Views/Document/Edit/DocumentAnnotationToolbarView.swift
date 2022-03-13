import UIKit

class DocumentAnnotationToolbarView: UIToolbar {
    @available(*, unavailable)
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override init(frame: CGRect) {
        super.init(frame: frame)

        let textButton = makeTextButton()
        let flexibleSpace = makeFlexibleSpace()
        self.items = [textButton, flexibleSpace]
    }

    private func makeTextButton() -> UIBarButtonItem {
        let button = UIButton(type: .system)
        let textFormatName = "textformat"
        button.setImage(UIImage(systemName: textFormatName), for: .normal)
        button.sizeToFit()
        return UIBarButtonItem(customView: button)
    }
}
