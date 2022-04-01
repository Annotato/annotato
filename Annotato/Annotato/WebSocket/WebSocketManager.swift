import Foundation
import AnnotatoSharedLibrary

class WebSocketManager {
    static let shared = WebSocketManager()
    private static let lastOnlineUserDefaultsKey = "lastOnline"
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
        socket?.resume()
    }

    func resetSocket() {
        socket?.cancel(with: .normalClosure, reason: nil)

        AnnotatoLogger.info("Websocket connection terminated...")
        socket = nil
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
                AnnotatoLogger.error(error.localizedDescription)
                let errorCode = (error as NSError).code
                if errorCode == WebSocketManager.unavailableDestinationHostErrorCode ||
                    errorCode == WebSocketManager.unconnectedSocketErrorCode ||
                    errorCode == WebSocketManager.connectionTimeOutErrorCode {
                    self.setLastOnline(to: Date())
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

    private func setLastOnline(to lastOnline: Date) {
        UserDefaults.standard.set(lastOnline, forKey: WebSocketManager.lastOnlineUserDefaultsKey)
    }

    func getLastOnline() -> Date? {
        guard let lastOnline = UserDefaults.standard.object(
            forKey: WebSocketManager.lastOnlineUserDefaultsKey) as? Date else {
            return nil
        }
        return lastOnline
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
