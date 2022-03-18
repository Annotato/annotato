import Foundation
import Vapor

class DocumentsWebSocketController {
    /// Each document has an associated set of connected websockets.
    private var openConnections: [UUID: Set<WebSocket>] = [:]

    func handleIncomingConnection(req: Request, webSocket: WebSocket) {
        guard let documentId = try? ControllersUtil.getIdFromParams(request: req) else {
            req.logger.info("Could not get document ID for request. Closing WebSocket connection...")
            _ = webSocket.close()
            return
        }

        req.logger.info("Client connected from Document with ID \(documentId)")
        addToOpenConnections(documentId: documentId, webSocket: webSocket)

        webSocket.onClose.whenComplete { [weak self] _ in
            req.logger.info("Client disconnected from Document with ID \(documentId)")
            self?.handleClosedConnection(documentId: documentId, webSocket: webSocket)
        }
    }

    private func handleClosedConnection(documentId: UUID, webSocket: WebSocket) {
        openConnections[documentId]?.remove(webSocket)

        if let remainingConnectionsForDocument = openConnections[documentId],
            remainingConnectionsForDocument.isEmpty {
            openConnections.removeValue(forKey: documentId)
        }
    }

    private func addToOpenConnections(documentId: UUID, webSocket: WebSocket) {
        var currentSocketsForDocument = openConnections[documentId, default: []]
        currentSocketsForDocument.insert(webSocket)
        openConnections[documentId] = currentSocketsForDocument
    }
}
