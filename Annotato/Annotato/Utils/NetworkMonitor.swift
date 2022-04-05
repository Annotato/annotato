import Network

class NetworkMonitor {
    static let shared = NetworkMonitor()

    private(set) var isConnected = false
    private let monitor = NWPathMonitor()

    func start() {
        monitor.start(queue: DispatchQueue.global())
        monitor.pathUpdateHandler = { [weak self] path in
            self?.isConnected = path.status == .satisfied
        }
    }

    func stop() {
        monitor.cancel()
    }
}
