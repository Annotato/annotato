import Foundation
import AnnotatoSharedLibrary

class WebSocketManager {
    static let shared = WebSocketManager()
    private static let unavailableDestinationHostErrorCode = 54
    private static let unconnectedSocketErrorCode = 57
    private static let connectionTimeOutErrorCode = 60

    private(set) var socket: URLSessionWebSocketTask?
    let documentManager = DocumentWebSocketManager()
    let annotationManager = AnnotationWebSocketManager()
    private(set) var isConnected = false

    private init() { }

    func setUpSocket() {
        guard let userId = AnnotatoAuth().currentUser?.uid else {
            AnnotatoLogger.error("Unable to retrieve user id.", context: "WebSocketManager::setUpSocket")
            return
        }

        guard let url = URL(string: "\(RemotePersistenceManager.baseWsAPIUrl)/ws/\(userId)") else {
            return
        }

        socket = URLSession(configuration: .default).webSocketTask(with: url)
        AnnotatoLogger.info("Websocket connection for user with id \(userId) setup successfully!")

        listen()
        checkConnection()
        socket?.resume()
    }

    func resetSocket() {
        socket?.cancel(with: .normalClosure, reason: nil)

        AnnotatoLogger.info("Websocket connection terminated...")
        socket = nil
    }

    func checkConnection() {
        socket?.sendPing { error in
            if error != nil {
                AnnotatoLogger.error("Websocket connection failed to receive ping from server.")

                if self.isConnected {
                    let currentDate = Date()

                    AnnotatoLogger.info("Setting last online time to \(currentDate)")
                    self.storeLastOnlineLocally(to: currentDate)
                    self.isConnected = false
                }

                self.isConnected = false
                sleep(2)
                self.checkConnection()
                return
            }

            self.isConnected = true

            print("Received ping")

            sleep(2)
            self.checkConnection()
        }
    }

    func listen() {
        AnnotatoLogger.info("Websocket connection listening for events...")

        socket?.receive { [weak self] result in
            guard let self = self else {
                return
            }
            switch result {
            case .failure(let error):
                AnnotatoLogger.error(error.localizedDescription)
            case .success(let message):
                self.isConnected = true
                switch message {
                case .data(let data):
                    self.handleResponseData(data: data)
                case .string(let str):
                    guard let data = str.data(using: .utf8) else {
                        return
                    }
                    self.handleResponseData(data: data)
                @unknown default:
                    break
                }
            }

            // We need to re-register the callback closure after a message is received
            self.listen()
        }
    }

    func send<T: Codable>(message: T) {
        do {
            AnnotatoLogger.info("Sending message: \(message) through websocket connection...")

            let data = try JSONCustomEncoder().encode(message)
            socket?.send(.data(data)) { error in
                if let error = error {
                    AnnotatoLogger.error(
                        "While sending data. \(error.localizedDescription).",
                        context: "WebSocketManager:send:"
                    )
                }
            }

        } catch {
            AnnotatoLogger.error(
                "When sending data. \(error.localizedDescription).",
                context: "WebSocketManager:send:"
            )
        }
    }

    private func handleResponseData(data: Data) {
        do {
            AnnotatoLogger.info("Handling response data...")

            let message = try JSONCustomDecoder().decode(AnnotatoMessage.self, from: data)

            switch message.type {
            case .crudDocument:
                documentManager.handleResponseData(data: data)
            case .crudAnnotation:
                annotationManager.handleResponseData(data: data)
            case .offlineToOnline:
                print("Not implemented yet. Do nothing.")
            }

        } catch {
            AnnotatoLogger.error(
                "When handling reponse data. \(error.localizedDescription).",
                context: "WebSocketManager:handleResponseData:"
            )
        }
    }
}

// MARK: Storing last online time in UserDefaults
extension WebSocketManager {
    private static let lastOnlineKey = "lastOnline"

    private func storeLastOnlineLocally(to lastOnline: Date) {
        UserDefaults.standard.set(lastOnline, forKey: WebSocketManager.lastOnlineKey)
    }

    func getLastOnline() -> Date? {
        if isConnected {
            return Date()
        }
        guard let lastOnline = UserDefaults.standard.object(
            forKey: WebSocketManager.lastOnlineKey) as? Date else {
            let value = UserDefaults.standard.object(forKey: WebSocketManager.lastOnlineKey)
            AnnotatoLogger.error("Failed to read last online from user defaults. We get: \(String(describing: value))",
                                 context: "WebSocketManager::getLastOnline")
            return nil
        }
        return lastOnline
    }
}
