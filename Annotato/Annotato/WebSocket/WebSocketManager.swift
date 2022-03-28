import Foundation
import AnnotatoSharedLibrary

class WebSocketManager {
    var socket: URLSessionWebSocketTask?

    func setSocket(to session: URLSessionWebSocketTask) {
        socket = session
        self.listen()
        socket?.resume()

        print("Set socket")
    }

    func resetSocket() {
        socket = nil
    }

    func listen() {
        guard let socket = socket else {
            return
        }

        socket.receive { [weak self] result in
            print(result)

            switch result {
            case .failure(let error):
                AnnotatoLogger.error(error.localizedDescription)
            case .success(let message):
                switch message {
                case .data(let data):
                    let annotation = try? JSONDecoder().decode(Annotation.self, from: data)
                    print(annotation)
                case .string(let str):
                    print(str)
                @unknown default:
                    break
                }
            }

            self?.listen()
        }
    }
}
