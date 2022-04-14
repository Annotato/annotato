import Foundation
import Combine
import AnnotatoSharedLibrary

class WebSocketManager: ObservableObject {
    private(set) var socket: URLSessionWebSocketTask?
    private var urlStringProducer: () -> String?
    private var cancellables: Set<AnyCancellable> = []

    @Published private(set) var message: Data?

    init(urlStringProducer: @escaping () -> String?) {
        self.urlStringProducer = urlStringProducer

        setUpSubscribers()
    }

    func setUpSocket() {
        guard let url = URL(string: urlStringProducer() ?? "") else {
            AnnotatoLogger.error("Invalid URL!", context: "WebSocketManager::setUpSocket")
            return
        }

        socket = URLSession(configuration: .default).webSocketTask(with: url)
        AnnotatoLogger.info("Websocket connection for \(url) setup successfully!")

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
        resetPublishedAttributes()

        AnnotatoLogger.info(
            "Publishing response data: \(String(data: data, encoding: .utf8))",
            context: "WebSocketManager::publishResponseData"
        )

        message = data

        resetPublishedAttributes()
    }

    private func resetPublishedAttributes() {
        message = nil
    }

    private func setUpSubscribers() {
        NetworkMonitor.shared.$isConnected.sink { [weak self] isConnected in
            if isConnected {
                self?.setUpSocket()
            }
        }.store(in: &cancellables)
    }
}
