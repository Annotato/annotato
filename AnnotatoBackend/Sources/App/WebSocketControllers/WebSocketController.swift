import Foundation
import Vapor
import AnnotatoSharedLibrary
import FluentKit

class WebSocketController {
    /// Each user has one websocket connection.
    private static var openConnections: [String: WebSocket] = [:]
    private static var logger = Logger(label: "WebSocketController")

    static func handleIncomingConnection(req: Request, webSocket: WebSocket) {
        guard let userId = try? ControllersUtil.getIdFromParamsAsString(request: req) else {
            req.logger.info("Could not get user ID for request. Closing WebSocket connection...")
            _ = webSocket.close()
            return
        }

        req.logger.info("Client with ID: \(userId) connected!")
        addToOpenConnections(userId: userId, webSocket: webSocket)

        webSocket.onBinary { ws, buffer in
            guard let data = buffer.getData(at: buffer.readerIndex, length: buffer.readableBytes) else {
                return
            }

            Task {
                await Self.handleIncomingData(userId: userId, ws: ws, data: data, db: req.db)
            }
        }

        webSocket.onText { ws, text in
            guard let data = text.data(using: .utf8) else {
                return
            }

            Task {
                await Self.handleIncomingData(userId: userId, ws: ws, data: data, db: req.db)
            }
        }

        webSocket.onClose.whenComplete { _ in
            req.logger.info("Client with ID: \(userId) disconnected!")
            Self.handleClosedConnection(userId: userId, webSocket: webSocket)
        }
    }

    static func sendToAllAppropriateClients<T: Codable>(userId: String, documentId: UUID, db: Database, message: T) {
        openConnections[userId]?.send(message: message)
        // TODO: SEND TO SHARED
    }

    private static func handleIncomingData(userId: String, ws: WebSocket, data: Data, db: Database) async {
        do {

            let message = try JSONDecoder().decode(AnnotatoMessage.self, from: data)

            switch message.type {
            case .crudDocument:
                await DocumentWebSocketController.handleCrudDocumentData(userId: userId, ws: ws, data: data, db: db)
            case .crudAnnotation:
                await AnnotationWebSocketController.handleCrudAnnotationData(userId: userId, ws: ws, data: data, db: db)
            case .offlineToOnline:
                print("Not implemented yet. Do nothing.")
            }

        } catch {
            Self.logger.error("Error when handling incoming data. \(error.localizedDescription)")
        }
    }

    private static func handleClosedConnection(userId: String, webSocket: WebSocket) {
        openConnections.removeValue(forKey: userId)
    }

    private static func addToOpenConnections(userId: String, webSocket: WebSocket) {
        openConnections[userId] = webSocket
    }
}
