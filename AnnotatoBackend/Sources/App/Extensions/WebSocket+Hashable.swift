import Vapor

extension WebSocket: Hashable {
    private static let logger = Logger(label: "WebSocket+Send")

    public static func == (lhs: WebSocket, rhs: WebSocket) -> Bool {
        ObjectIdentifier(lhs) == ObjectIdentifier(rhs)
    }

    public func hash(into hasher: inout Hasher) {
        hasher.combine(ObjectIdentifier(self))
    }

    func send<T: Codable>(message: T) {
        do {
            let data = try JSONEncoder().encode(message)
            self.send(raw: data, opcode: .binary)
        } catch {
            WebSocket.logger.report(error: error)
        }
    }
}
