import Combine
import UIKit

class OfflineToOnlineViewController: UIViewController, SpinnerPresentable {
    let spinner = UIActivityIndicatorView(style: .large)

    private var cancellables: Set<AnyCancellable> = []

    override func viewDidLoad() {
        super.viewDidLoad()
        initializeSpinner()
        setUpSubscribers()
    }

    private func setUpSubscribers() {

    }

    @IBAction private func didTapDiscardLocalChanges(_ sender: Any) {
        startSpinner()
    }

    @IBAction private func didTapOverrideWithLocalChanges(_ sender: Any) {
        startSpinner()
    }

}
