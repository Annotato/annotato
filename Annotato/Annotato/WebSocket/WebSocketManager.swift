import Foundation
import AnnotatoSharedLibrary

class WebSocketManager: ObservableObject {
    static let shared = WebSocketManager()

    private(set) var socket: URLSessionWebSocketTask?

    @Published private(set) var message: Data?

    private init() { }

    func setUpSocket() {
        guard let userId = AuthViewModel().currentUser?.id else {
            AnnotatoLogger.error("Unable to retrieve user id.", context: "WebSocketManager::setUpSocket")
            return
        }

        guard let url = URL(string: "\(RemotePersistenceService.baseWsAPIUrl)/ws/\(userId)") else {
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

        socket?.receive { [weak self] result in
            switch result {
            case .failure(let error):
                AnnotatoLogger.error(error.localizedDescription)
            case .success(let message):
                switch message {
                case .data(let data):
                    self?.publishResponseData(data: data)
                case .string(let str):
                    guard let data = str.data(using: .utf8) else {
                        return
                    }
                    self?.publishResponseData(data: data)
                @unknown default:
                    break
                }
            }

            // We need to re-register the callback closure after a message is received
            self?.listen()
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
                        context: "WebSocketManager::send"
                    )
                }
            }

        } catch {
            AnnotatoLogger.error(
                "When sending data. \(error.localizedDescription).",
                context: "WebSocketManager::send"
            )
        }
    }

    private func publishResponseData(data: Data) {
        AnnotatoLogger.info(
            "Publishing response data...",
            context: "WebSocketManager::publishResponseData"
        )

        message = data
    }
}
