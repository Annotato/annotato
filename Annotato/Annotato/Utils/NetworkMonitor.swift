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

            if !self.isConnected {
                let date = Date()
                AnnotatoLogger.info("Setting last online datetime to \(date)")
                self.setLastOnlineDatetime(to: date)
            }

            AnnotatoLogger.info("Current connection status: \(self.isConnected)")
        }
    }
}

// MARK: Storing last online time in UserDefaults
extension NetworkMonitor {
    private static let lastOnlineDatetimeKey = "lastOnlineDatetime"

    private func setLastOnlineDatetime(to lastOnlineDatetime: Date) {
        UserDefaults.standard.set(lastOnlineDatetime, forKey: Self.lastOnlineDatetimeKey)
    }

    func getLastOnlineDatetime() -> Date? {
        guard let lastOnlineDatetime = UserDefaults.standard.object(
            forKey: Self.lastOnlineDatetimeKey
        ) as? Date else {
            let value = UserDefaults.standard.object(forKey: Self.lastOnlineDatetimeKey)
            AnnotatoLogger.error("Failed to read last online from user defaults. We get: \(String(describing: value))",
                                 context: "NetworkMonitor::getLastOnlineDatetime")
            return nil
        }

        return lastOnlineDatetime
    }
}
