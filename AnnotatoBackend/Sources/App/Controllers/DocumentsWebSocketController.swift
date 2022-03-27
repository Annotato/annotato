import Foundation
import Vapor

class DocumentsWebSocketController {
    /// Each document has an associated set of connected websockets.
    private static var openConnections: [UUID: Set<WebSocket>] = [:]

    static func handleIncomingConnection(req: Request, webSocket: WebSocket) {
        guard let documentId = try? ControllersUtil.getIdFromParams(request: req) else {
            req.logger.info("Could not get document ID for request. Closing WebSocket connection...")
            _ = webSocket.close()
            return
        }

        req.logger.info("Client connected from Document with ID \(documentId)")
        addToOpenConnections(documentId: documentId, webSocket: webSocket)

        webSocket.onText(handleIncomingText(documentId: documentId))

        webSocket.onClose.whenComplete { _ in
            req.logger.info("Client disconnected from Document with ID \(documentId)")
            Self.handleClosedConnection(documentId: documentId, webSocket: webSocket)
        }
    }

    private static func handleIncomingText(documentId: UUID) -> (WebSocket, String) -> Void {
        { webSocket, text in
            guard let currentOpenConnections = self.openConnections[documentId] else {
                return
            }

            for socket in currentOpenConnections {
                socket.send(text)
            }
        }
    }

    private static func handleClosedConnection(documentId: UUID, webSocket: WebSocket) {
        openConnections[documentId]?.remove(webSocket)

        if let remainingConnectionsForDocument = openConnections[documentId],
            remainingConnectionsForDocument.isEmpty {
            openConnections.removeValue(forKey: documentId)
        }
    }

    private static func addToOpenConnections(documentId: UUID, webSocket: WebSocket) {
        var currentSocketsForDocument = openConnections[documentId, default: []]
        currentSocketsForDocument.insert(webSocket)
        openConnections[documentId] = currentSocketsForDocument
    }
}
