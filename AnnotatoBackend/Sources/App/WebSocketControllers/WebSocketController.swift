import Foundation
import Vapor
import AnnotatoSharedLibrary
import FluentKit

class WebSocketController {
    /// Each user has one websocket connection.
    private static var openConnections: [String: WebSocket] = [:]
    private static var logger = Logger(label: "WebSocketController")

    static func handleIncomingConnection(req: Request, webSocket: WebSocket) {
        guard let userId = try? ControllersUtil.getParamValue(request: req, paramKey: "userId") else {
            req.logger.info("Could not get user ID for request. Closing WebSocket connection...")
            _ = webSocket.close()
            return
        }

        req.logger.info("Client with ID: \(userId) connected!")
        addToOpenConnectionsIfNotConnected(userId: userId, webSocket: webSocket)

        webSocket.onBinary(handleBinaryData(userId: userId, db: req.db))
        webSocket.onText(handleTextData(userId: userId, db: req.db))

        webSocket.onClose.whenComplete { _ in
            req.logger.info("Client with ID: \(userId) disconnected!")
            Self.handleClosedConnection(userId: userId)
        }
    }

    static func sendAll<T: Codable>(recipientIds: Set<String>, message: T) {
        for (userId, ws) in openConnections where recipientIds.contains(userId) {
            ws.send(message: message)
        }
    }

    private static func handleBinaryData(userId: String, db: Database) -> (WebSocket, ByteBuffer) -> Void {
        { _, buffer in
            guard let data = buffer.getData(at: buffer.readerIndex, length: buffer.readableBytes) else {
                return
            }

            Task {
                await Self.handleIncomingData(userId: userId, data: data, db: db)
            }
        }
    }

    private static func handleTextData(userId: String, db: Database) -> (WebSocket, String) -> Void {
        { _, text in
            guard let data = text.data(using: .utf8) else {
                return
            }

            Task {
                await Self.handleIncomingData(userId: userId, data: data, db: db)
            }
        }
    }

    private static func handleIncomingData(userId: String, data: Data, db: Database) async {
        do {

            let message = try JSONDecoder().decode(AnnotatoMessage.self, from: data)

            switch message.type {
            case .crudDocument:
                await DocumentWebSocketController.handleCrudDocumentData(userId: userId, data: data, db: db)
            case .crudAnnotation:
                await AnnotationWebSocketController.handleCrudAnnotationData(userId: userId, data: data, db: db)
            case .offlineToOnline:
                print("Not implemented yet. Do nothing.")
            }

        } catch {
            Self.logger.error("Error when handling incoming data. \(error.localizedDescription)")
        }
    }

    private static func addToOpenConnectionsIfNotConnected(userId: String, webSocket: WebSocket) {
        if openConnections[userId] != nil {
            Self.logger.error("Client with \(userId) already has an open connection! Closing WebSocket connection...")
            _ = webSocket.close()
        }

        openConnections[userId] = webSocket
    }

    private static func handleClosedConnection(userId: String) {
        openConnections.removeValue(forKey: userId)
    }
}
