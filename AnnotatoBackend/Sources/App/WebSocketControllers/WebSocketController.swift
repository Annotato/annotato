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
        addToOpenConnections(userId: userId, incomingWebSocket: webSocket)

        webSocket.onBinary(handleBinaryData(userId: userId, db: req.db))
        webSocket.onText(handleTextData(userId: userId, db: req.db))

        webSocket.onClose.whenComplete { _ in
            Self.logger.info("Closed websocket connection for user with id \(userId)")
        }
    }

    static func sendAll<T: Codable>(recipientIds: Set<String>, message: T) {
        for (userId, ws) in openConnections where recipientIds.contains(userId) {
            Self.logger.info("Sending to user with id \(userId)")

            ws.send(message: message)
        }
    }

    private static func handleBinaryData(userId: String, db: Database) -> (WebSocket, ByteBuffer) -> Void {
        { _, buffer in
            guard let data = buffer.getData(at: buffer.readerIndex, length: buffer.readableBytes) else {
                return
            }

            Self.logger.info("Received binary data...")

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

            Self.logger.info("Received text data...")

            Task {
                await Self.handleIncomingData(userId: userId, data: data, db: db)
            }
        }
    }

    private static func handleIncomingData(userId: String, data: Data, db: Database) async {
        do {
            Self.logger.info("Processing data...")

            let message = try JSONCustomDecoder().decode(AnnotatoMessage.self, from: data)

            switch message.type {
            case .crudDocument:
                await DocumentWebSocketController.handleCrudDocumentData(userId: userId, data: data, db: db)
            case .crudAnnotation:
                await AnnotationWebSocketController.handleCrudAnnotationData(userId: userId, data: data, db: db)
            case .offlineToOnline:
                await OfflineToOnlineWebSocketController.handleOfflineToOnlineResolution(
                    userId: userId, data: data, db: db)
            }
        } catch {
            Self.logger.error("Error when handling incoming data. \(error.localizedDescription)")
        }
    }

    private static func addToOpenConnections(userId: String, incomingWebSocket: WebSocket) {
        if let existingWebSocket = openConnections[userId] {
            Self.logger.error("Closing previous WebSocket connection for user with id \(userId)...")
            _ = existingWebSocket.close()
            openConnections.removeValue(forKey: userId)
        }

        Self.logger.info("Adding new websocket connection for user with id \(userId)")

        openConnections[userId] = incomingWebSocket
    }
}
