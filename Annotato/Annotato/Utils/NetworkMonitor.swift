import Foundation
import Network
import Combine

class NetworkMonitor: ObservableObject {
    static let shared = NetworkMonitor()

    @Published private(set) var isConnected = false
    private let queue = DispatchQueue.global()
    private let monitor = NWPathMonitor()

    func start(webSocketManager: WebSocketManager?) {
        monitor.start(queue: queue)
        monitor.pathUpdateHandler = { [weak self] path in
            AnnotatoLogger.info("Detected a change in internet connection status...")

            guard let self = self else {
                return
            }

            let isCurrentlyConnected = path.status == .satisfied

            if self.isConnected != isCurrentlyConnected {
                self.isConnected = isCurrentlyConnected
                AnnotatoLogger.info("Setting isConnected to \(self.isConnected)")
            }
        }
    }

    func stop() {
        monitor.cancel()
    }
}
