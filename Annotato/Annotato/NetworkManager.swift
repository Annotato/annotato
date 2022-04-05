import Network

class NetworkManager {
    static let shared = NetworkManager()

    private(set) var isConnected = false

    private let queue = DispatchQueue.global()
    private let monitor = NWPathMonitor()

    func start() {
        monitor.start(queue: queue)
        monitor.pathUpdateHandler = { [weak self] path in
            self?.isConnected = path.status == .satisfied
            print(self?.isConnected ?? "n/a")
        }
    }

    func stop() {
        monitor.cancel()
    }
}
