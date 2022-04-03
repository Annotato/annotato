import Foundation
import AnnotatoSharedLibrary

class WebSocketManager {
    static let shared = WebSocketManager()
    private static let unavailableDestinationHostErrorCode = 54
    private static let unconnectedSocketErrorCode = 57
    private static let connectionTimeOutErrorCode = 60
    private static let offlineInternetConnection = -1_009

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
        socket?.resume()
        pingServer()
        timerTriggerToUpdateLastOnline()
    }

    func resetSocket() {
        socket?.cancel(with: .normalClosure, reason: nil)

        AnnotatoLogger.info("Websocket connection terminated...")
        socket = nil
    }

    private func pingServer() {
        guard let socket = socket else {
            self.isConnected = false
            return
        }
        socket.sendPing(pongReceiveHandler: { [weak self] err in
            guard let self = self else {
                return
            }
            if err == nil {
                self.isConnected = true
                self.storeLastOnlineLocally(to: Date())
            } else {
                self.isConnected = false
            }
        })
    }

    private func timerTriggerToUpdateLastOnline() {
        Timer.scheduledTimer(withTimeInterval: 10.0, repeats: true, block: { _ in
            self.pingServer()
            if self.isConnected {
                self.storeLastOnlineLocally(to: Date())
            } else {
                self.resetSocket()
                self.setUpSocket()
            }
        })
    }

    func listen() {
        AnnotatoLogger.info("Websocket connection listening for events...")

        // swiftlint:disable closure_body_length
        socket?.receive { [weak self] result in
            guard let self = self else {
                return
            }
            switch result {
            case .failure(let error):
                let errorCode = (error as NSError).code
                AnnotatoLogger.error(error.localizedDescription + " errorCode: \(errorCode)")
                if errorCode == WebSocketManager.unavailableDestinationHostErrorCode ||
                    errorCode == WebSocketManager.unconnectedSocketErrorCode ||
                    errorCode == WebSocketManager.connectionTimeOutErrorCode ||
                    errorCode == WebSocketManager.offlineInternetConnection {
                    self.isConnected = false
                }
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
