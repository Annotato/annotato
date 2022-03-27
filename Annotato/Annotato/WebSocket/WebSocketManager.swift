import Foundation

class WebSocketManager {
    var socket: URLSessionWebSocketTask?

    func setSocket(to session: URLSessionWebSocketTask) {
        socket = session
        listen()
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
            guard let self = self else {
                return
            }

            print(result)

            switch result {
            case .failure(let error):
                AnnotatoLogger.error(error.localizedDescription)
            case .success(let message):
                switch message {
                case .data(let data):
                    print(data)
                case .string(let str):
                    print(str)
                @unknown default:
                    break
                }
            }

            self.listen()
        }
    }
}
