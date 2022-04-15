import UIKit
import Combine

class SelectionBoxView: UIView {
    private(set) var presenter: SelectionBoxPresenter
    private var cancellables: Set<AnyCancellable> = []

    @available(*, unavailable)
    required init(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    init(presenter: SelectionBoxPresenter) {
        self.presenter = presenter
        super.init(frame: presenter.frame)
        setUpSubscribers()
        self.layer.borderWidth = 2.0
        self.layer.zPosition = 1.0
        self.layer.borderColor = UIColor.systemGray3.cgColor
    }

    private func setUpSubscribers() {
        presenter.$isRemoved.sink(receiveValue: { [weak self] isRemoved in
            if isRemoved {
                DispatchQueue.main.async {
                    self?.removeFromSuperview()
                }
            }
        }).store(in: &cancellables)
    }
}
