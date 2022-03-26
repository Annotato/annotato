import UIKit
import Combine

class SelectionBoxView: UIView {
    private(set) var viewModel: SelectionBoxViewModel
    private var cancellables: Set<AnyCancellable> = []

    @available(*, unavailable)
    required init(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    init(viewModel: SelectionBoxViewModel) {
        self.viewModel = viewModel
        super.init(frame: viewModel.frame)
        setUpSubscribers()
        self.layer.borderWidth = 1.0
        self.layer.borderColor = UIColor.systemRed.cgColor
    }

    private func setUpSubscribers() {
        viewModel.$endPointDidChange.sink(receiveValue: { [weak self] _ in
            guard let newSelectionBoxFrame = self?.viewModel.frame else {
                return
            }
            self?.frame = newSelectionBoxFrame
        }).store(in: &cancellables)

        viewModel.$isRemoved.sink(receiveValue: { [weak self] isRemoved in
            if isRemoved {
                self?.removeFromSuperview()
            }
        }).store(in: &cancellables)
    }
}
