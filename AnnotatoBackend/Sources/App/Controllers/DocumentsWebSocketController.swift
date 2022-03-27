import Foundation
import Vapor
import AnnotatoSharedLibrary
import FluentKit

class DocumentsWebSocketController {
    /// Each document has an associated set of connected websockets.
    private static var openConnections: [UUID: Set<WebSocket>] = [:]
    private static var logger = Logger(label: "DocumentsWebSocketController")

    static func handleIncomingConnection(req: Request, webSocket: WebSocket) {
        guard let documentId = try? ControllersUtil.getIdFromParams(request: req) else {
            req.logger.info("Could not get document ID for request. Closing WebSocket connection...")
            _ = webSocket.close()
            return
        }

        req.logger.info("Client connected from Document with ID \(documentId)")
        addToOpenConnections(documentId: documentId, webSocket: webSocket)

        webSocket.onBinary { ws, buffer in
            guard let data = buffer.getData(at: buffer.readerIndex, length: buffer.readableBytes) else {
                return
            }

            Task {
                await handleIncomingData(documentId: documentId, ws, data, req.db)
            }
        }

        webSocket.onText { ws, text in
            guard let data = text.data(using: .utf8) else {
                return
            }

            Task {
                await handleIncomingData(documentId: documentId, ws, data, req.db)
            }
        }

        webSocket.onClose.whenComplete { _ in
            req.logger.info("Client disconnected from Document with ID \(documentId)")
            Self.handleClosedConnection(documentId: documentId, webSocket: webSocket)
        }
    }

    private static func handleIncomingData(documentId: UUID, _ ws: WebSocket, _ data: Data, _ db: Database) async {
        do {
            let message = try JSONDecoder().decode(AnnotatoWebSocketMessage.self, from: data)

            switch message.type {
            case .create:
                await handleCreate(message.modelType, documentId, ws, data, db)
            case .update:
                await handleUpdate(message.modelType, documentId, ws, data, db)
            case .read:
                await handleRead(message.modelType, documentId, ws, data, db)
            case .delete:
                await handleDelete(message.modelType, documentId, ws, data, db)
            }

        } catch {
            Self.logger.error("\(error.localizedDescription)")
        }
    }

    private static func handleCreate(
        _ modelType: ModelType,
        _ documentId: UUID,
        _ ws: WebSocket,
        _ data: Data,
        _ db: Database
    ) async {
        switch modelType {
        case .document:
            Self.logger.error("Creating documents through websocket is not supported.")
        case .annotation:
            await Self.handleCreateAnnotation(documentId, ws, data, db)
        }
    }

    private static func handleUpdate(
        _ modelType: ModelType,
        _ documentId: UUID,
        _ ws: WebSocket,
        _ data: Data,
        _ db: Database
    ) async {
        switch modelType {
        case .document:
            await Self.handleUpdateDocument(documentId, ws, data, db)
        case .annotation:
            await Self.handleUpdateAnnotation(documentId, ws, data, db)
        }
    }

    private static func handleRead(
        _ modelType: ModelType,
        _ documentId: UUID,
        _ ws: WebSocket,
        _ data: Data,
        _ db: Database
    ) async {
        switch modelType {
        case .document:
            await Self.handleReadDocument(documentId, ws, data, db)
        case .annotation:
            await Self.handleReadAnnotation(documentId, ws, data, db)
        }
    }

    private static func handleDelete(
        _ modelType: ModelType,
        _ documentId: UUID,
        _ ws: WebSocket,
        _ data: Data,
        _ db: Database
    ) async {
        switch modelType {
        case .document:
            await Self.handleDeleteDocument(documentId, ws, data, db)
        case .annotation:
            await Self.handleDeleteAnnotation(documentId, ws, data, db)
        }
    }

    private static func handleUpdateDocument(_ documentId: UUID, _ ws: WebSocket, _ data: Data, _ db: Database) async {
        do {
            let documentMessage = try JSONDecoder().decode(AnnotatoDocumentMessage.self, from: data)

            let updatedDocument = try await DocumentsDataAccess.update(
                db: db, documentId: documentId, document: documentMessage.document
            )

            sendToAllConnectedClients(documentId: documentId, message: updatedDocument)
        } catch {
            Self.logger.error("Unable to update document. \(error.localizedDescription)")
        }
    }

    private static func handleReadDocument(_ documentId: UUID, _ ws: WebSocket, _ data: Data, _ db: Database) async {
        do {
            let document = try await DocumentsDataAccess.read(db: db, documentId: documentId)

            sendToAllConnectedClients(documentId: documentId, message: document)
        } catch {
            Self.logger.error("Unable to read document. \(error.localizedDescription)")
        }
    }

    private static func handleDeleteDocument(_ documentId: UUID, _ ws: WebSocket, _ data: Data, _ db: Database) async {
        do {
            let deletedDocument = try await DocumentsDataAccess.delete(db: db, documentId: documentId)

            sendToAllConnectedClients(documentId: documentId, message: deletedDocument)
        } catch {
            Self.logger.error("Unable to delete document. \(error.localizedDescription)")
        }
    }

    private static func handleCreateAnnotation(
        _ documentId: UUID,
        _ ws: WebSocket,
        _ data: Data,
        _ db: Database
    ) async {
        do {
            let annotationMessage = try JSONDecoder().decode(AnnotatoAnnotationMessage.self, from: data)

            let newAnnotation = try await AnnotationDataAccess.create(db: db, annotation: annotationMessage.annotation)

            sendToAllConnectedClients(documentId: documentId, message: newAnnotation)
        } catch {
            Self.logger.error("Unable to create annotation. \(error.localizedDescription)")
        }
    }

    private static func handleReadAnnotation(_ documentId: UUID, _ ws: WebSocket, _ data: Data, _ db: Database) async {
        do {
            let annotationMessage = try JSONDecoder().decode(AnnotatoAnnotationMessage.self, from: data)

            let annotation = try await AnnotationDataAccess.read(db: db, annotationId: annotationMessage.annotation.id)

            sendToAllConnectedClients(documentId: documentId, message: annotation)
        } catch {
            Self.logger.error("Unable to read annotation. \(error.localizedDescription)")
        }
    }

    private static func handleUpdateAnnotation(
        _ documentId: UUID,
        _ ws: WebSocket,
        _ data: Data,
        _ db: Database
    ) async {
        do {
            let annotationMessage = try JSONDecoder().decode(AnnotatoAnnotationMessage.self, from: data)

            let updatedAnnotation = try await AnnotationDataAccess.update(
                db: db, annotationId: annotationMessage.annotation.id, annotation: annotationMessage.annotation
            )

            sendToAllConnectedClients(documentId: documentId, message: updatedAnnotation)
        } catch {
            Self.logger.error("Unable to update annotation. \(error.localizedDescription)")
        }
    }

    private static func handleDeleteAnnotation(
        _ documentId: UUID,
        _ ws: WebSocket,
        _ data: Data,
        _ db: Database
    ) async {
        do {
            let annotationMessage = try JSONDecoder().decode(AnnotatoAnnotationMessage.self, from: data)

            let deletedAnnotation = try await AnnotationDataAccess.delete(
                db: db, annotationId: annotationMessage.annotation.id
            )

            sendToAllConnectedClients(documentId: documentId, message: deletedAnnotation)
        } catch {
            Self.logger.error("Unable to delete annotation. \(error.localizedDescription)")
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

    private static func sendToAllConnectedClients<T: Codable>(documentId: UUID, message: T) {
        guard let currentOpenConnections = self.openConnections[documentId] else {
            return
        }

        for socket in currentOpenConnections {
            socket.send(message: message)
        }
    }
}
