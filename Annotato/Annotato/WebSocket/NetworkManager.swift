import Foundation
import Reachability

class NetworkManager: NSObject {
    var reachability: Reachability!
    static let sharedInstance = NetworkManager()

    override init() {
        super.init()
        // Initialise reachability
        reachability = try? Reachability()
        // Register an observer for the network status
        NotificationCenter.default.addObserver(
            self,
            selector: #selector(networkStatusChanged(_:)),
            name: .reachabilityChanged,
            object: reachability
        )
        do {
            // Start the network status notifier
            try reachability.startNotifier()
        } catch {
            print("Unable to start notifier")
        }
    }

    @objc
    func networkStatusChanged(_ notification: Notification) {
        print("Network status changed")
        print(notification.description)
    }
}
