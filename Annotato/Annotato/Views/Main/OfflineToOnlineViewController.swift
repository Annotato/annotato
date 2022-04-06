import Combine
import UIKit

class OfflineToOnlineViewController: UIViewController, Navigable, SpinnerPresentable {
    let spinner = UIActivityIndicatorView(style: .large)

    private var hasRequestedForResolution = false
    private var cancellables: Set<AnyCancellable> = []

    override func viewDidLoad() {
        super.viewDidLoad()
        initializeSpinner()
        setUpSubscribers()
    }

    private func setUpSubscribers() {
        WebSocketManager.shared.offlineToOnlineManager.$isResolvingChanges
            .sink(receiveValue: { [weak self] isResolvingChanges in
                guard self?.hasRequestedForResolution ?? false else {
                    return
                }

                if isResolvingChanges {
                    DispatchQueue.main.async {
                        self?.startSpinner()
                    }
                } else {
                    DispatchQueue.main.async {
                        self?.stopSpinner()
                        self?.goBackWithRefresh()
                    }
                }
            }).store(in: &cancellables)
    }

    @IBAction private func didTapDiscardLocalChanges(_ sender: Any) {
        hasRequestedForResolution = true
        WebSocketManager.shared.offlineToOnlineManager.sendOnlineMessage(mergeStrategy: .keepServerVersion)
    }

    @IBAction private func didTapOverrideWithLocalChanges(_ sender: Any) {
        hasRequestedForResolution = true
        WebSocketManager.shared.offlineToOnlineManager.sendOnlineMessage(mergeStrategy: .overrideServerVersion)
    }
}
