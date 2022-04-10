import Foundation
import Vapor
import AnnotatoSharedLibrary
import FluentKit

class WebSocketController {
    // Child Controllers
    lazy var documentWebSocketController = DocumentWebSocketController(parentController: self)
    lazy var annotationWebSocketController = AnnotationWebSocketController(parentController: self)

    // Each user has one websocket connection. User ID is represented as a string.
    private var openConnections: [String: WebSocket] = [:]

    private let logger = Logger(label: "WebSocketController")

    func handleIncomingConnection(req: Request, webSocket: WebSocket) {
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
            self.logger.info("Closed websocket connection for user with id \(userId)")
        }
    }

    func sendAll<T: Codable>(recipientIds: Set<String>, message: T) {
        for (userId, ws) in openConnections where recipientIds.contains(userId) {
            self.logger.info("Sending to user with id \(userId)")

            ws.send(message: message)
        }
    }

    func handleBinaryData(userId: String, db: Database) -> (WebSocket, ByteBuffer) -> Void {
        { _, buffer in
            guard let data = buffer.getData(at: buffer.readerIndex, length: buffer.readableBytes) else {
                return
            }

            self.logger.info("Received binary data...")

            Task {
                await self.handleIncomingData(userId: userId, data: data, db: db)
            }
        }
    }

    func handleTextData(userId: String, db: Database) -> (WebSocket, String) -> Void {
        { _, text in
            guard let data = text.data(using: .utf8) else {
                return
            }

            self.logger.info("Received text data...")

            Task {
                await self.handleIncomingData(userId: userId, data: data, db: db)
            }
        }
    }

    func handleIncomingData(userId: String, data: Data, db: Database) async {
        do {
            self.logger.info("Processing data...")

            let message = try JSONCustomDecoder().decode(AnnotatoMessage.self, from: data)

            switch message.type {
            case .crudDocument:
                await documentWebSocketController.handleCrudDocumentData(userId: userId, data: data, db: db)
            case .crudAnnotation:
                await annotationWebSocketController.handleCrudAnnotationData(userId: userId, data: data, db: db)
            }
        } catch {
            self.logger.error("Error when handling incoming data. \(error.localizedDescription)")
        }
    }

    func addToOpenConnections(userId: String, incomingWebSocket: WebSocket) {
        if let existingWebSocket = openConnections[userId] {
            self.logger.error("Closing previous WebSocket connection for user with id \(userId)...")
            _ = existingWebSocket.close()
            openConnections.removeValue(forKey: userId)
        }

        self.logger.info("Adding new websocket connection for user with id \(userId)")

        openConnections[userId] = incomingWebSocket
    }
}
