import Foundation
import Network
import Combine

class NetworkMonitor: ObservableObject {
    static let shared = NetworkMonitor()

    @Published private(set) var isConnected = false
    private let queue = DispatchQueue.global()
    private let monitor = NWPathMonitor()

    func start() {
        monitor.start(queue: queue)
        monitor.pathUpdateHandler = { [weak self] path in
            AnnotatoLogger.info("Detected a change in internet connection status...")

            guard let self = self else {
                return
            }

            let isCurrentlyConnected = path.status == .satisfied

            // If user goes from offline to online, re-establish websocket connection
            if !self.isConnected && isCurrentlyConnected {
                WebSocketManager.shared.resetSocket()
                WebSocketManager.shared.setUpSocket()
            }

            self.isConnected = isCurrentlyConnected
            AnnotatoLogger.info("Setting isConnected to \(self.isConnected)")

            if !self.isConnected {
                let date = Date()
                AnnotatoLogger.info("Setting last online datetime to \(date)")
                self.setLastOnlineDatetime(to: date)
            }
        }
    }

    func stop() {
        monitor.cancel()
    }
}

// MARK: Storing last online time in UserDefaults
extension NetworkMonitor {
    private static let lastOnlineDatetimeKey = "lastOnlineDatetime"

    private func setLastOnlineDatetime(to lastOnlineDatetime: Date) {
        UserDefaults.standard.set(lastOnlineDatetime, forKey: Self.lastOnlineDatetimeKey)
    }

    func getLastOnlineDatetime() -> Date? {
        if isConnected {
            return Date()
        }

        guard let lastOnlineDatetime = UserDefaults.standard.object(
            forKey: Self.lastOnlineDatetimeKey
        ) as? Date else {
            let value = UserDefaults.standard.object(forKey: Self.lastOnlineDatetimeKey)
            AnnotatoLogger.error("Failed to read last online from user defaults. We get: \(String(describing: value))",
                                 context: "NetworkMonitor::getLastOnline")
            return nil
        }

        return lastOnlineDatetime
    }
}
