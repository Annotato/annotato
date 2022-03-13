import UIKit

class FilledButton: UIButton {
    @available(*, unavailable)
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    required init(title: String, frame: CGRect) {
        super.init(frame: frame)

        self.setTitle(title, for: .normal)
        self.configuration = .filled()
        self.titleLabel?.adjustsFontSizeToFitWidth = true
    }
}
