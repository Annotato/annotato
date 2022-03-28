import Foundation
import AnnotatoSharedLibrary

class WebSocketManager {
    let socket: URLSessionWebSocketTask
    let documentManager = DocumentWebSocketManager()
    let annotationManager = AnnotationWebSocketManager()

    init?() {
        guard let userId = AnnotatoAuth().currentUser?.uid else {
            AnnotatoLogger.error("Unable to retrieve user id.", context: "WebSocketManager::init")
            return nil
        }

        guard let url = URL(string: "\(BaseAPI.baseWsAPIUrl)/ws/\(userId)") else {
            return nil
        }

        socket = URLSession(configuration: .default).webSocketTask(with: url)
        listen()
        socket.resume()
    }

    func listen() {
        socket.receive { [weak self] result in
            guard let self = self else {
                return
            }

            switch result {
            case .failure(let error):
                AnnotatoLogger.error(error.localizedDescription)
            case .success(let message):
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

    private func handleResponseData(data: Data) {
        do {

            let message = try JSONDecoder().decode(AnnotatoMessage.self, from: data)

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
