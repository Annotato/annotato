import Foundation
import Network

class NetworkMonitor {
    static let shared = NetworkMonitor()

    private(set) var isConnected = false
    private let monitor = NWPathMonitor()

    func start() {
        monitor.start(queue: DispatchQueue.global())
        monitor.pathUpdateHandler = { [weak self] path in
            AnnotatoLogger.info("Detected a change in internet connection status...")

            guard let self = self else {
                return
            }

            self.isConnected = path.status == .satisfied
            AnnotatoLogger.info("Setting isConnected to \(self.isConnected)")

            if !self.isConnected {
                let date = Date()
                AnnotatoLogger.info("Setting last online date to \(date)")
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
