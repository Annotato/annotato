import Foundation
import Vapor
import AnnotatoSharedLibrary
import FluentKit

class DocumentWebSocketController {
    private static var logger = Logger(label: "DocumentWebSocketController")

    static func handleCrudDocumentData(userId: String, ws: WebSocket, data: Data, db: Database) async {
        do {

            let message = try JSONDecoder().decode(AnnotatoCrudDocumentMessage.self, from: data)

            switch message.subtype {
            case .createDocument:
                await Self.handleCreateDocument(userId: userId, ws: ws, db: db, document: message.document)
            case .readDocument:
                await Self.handleReadDocument(userId: userId, ws: ws, db: db, document: message.document)
            case .updateDocument:
                await Self.handleUpdateDocument(userId: userId, ws: ws, db: db, document: message.document)
            case .deleteDocument:
                await Self.handleDeleteDocument(userId: userId, ws: ws, db: db, document: message.document)
            }

        } catch {
            Self.logger.error("Error when handling incoming crud document data. \(error.localizedDescription)")
        }
    }

    private static func handleCreateDocument(userId: String, ws: WebSocket, db: Database, document: Document) async {
        do {

            let newDocument = try await DocumentsDataAccess.create(db: db, document: document)
            let response = AnnotatoCrudDocumentMessage(subtype: .createDocument, document: newDocument)

            await WebSocketController
                .sendToAllAppropriateClients(userId: userId, documentId: newDocument.id, db: db, message: response)

        } catch {
            Self.logger.error("Error when creating document. \(error.localizedDescription)")
        }
    }

    private static func handleReadDocument(userId: String, ws: WebSocket, db: Database, document: Document) async {
        do {

            let readDocument = try await DocumentsDataAccess.read(db: db, documentId: document.id)
            let response = AnnotatoCrudDocumentMessage(subtype: .readDocument, document: readDocument)

            await WebSocketController
                .sendToAllAppropriateClients(userId: userId, documentId: readDocument.id, db: db, message: response)

        } catch {
            Self.logger.error("Error when reading document. \(error.localizedDescription)")
        }
    }

    private static func handleUpdateDocument(userId: String, ws: WebSocket, db: Database, document: Document) async {
        do {

            let updatedDocument = try await DocumentsDataAccess
                .update(db: db, documentId: document.id, document: document)
            let response = AnnotatoCrudDocumentMessage(subtype: .updateDocument, document: updatedDocument)

            await WebSocketController
                .sendToAllAppropriateClients(userId: userId, documentId: updatedDocument.id, db: db, message: response)

        } catch {
            Self.logger.error("Error when updating document. \(error.localizedDescription)")
        }
    }

    private static func handleDeleteDocument(userId: String, ws: WebSocket, db: Database, document: Document) async {
        do {

            let deletedDocument = try await DocumentsDataAccess.delete(db: db, documentId: document.id)
            let response = AnnotatoCrudDocumentMessage(subtype: .deleteDocument, document: deletedDocument)

            await WebSocketController
                .sendToAllAppropriateClients(userId: userId, documentId: deletedDocument.id, db: db, message: response)

        } catch {
            Self.logger.error("Error when deleting document. \(error.localizedDescription)")
        }
    }
}
