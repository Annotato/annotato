import Foundation
import Vapor
import AnnotatoSharedLibrary
import FluentKit

class DocumentWebSocketController {
    private static var logger = Logger(label: "DocumentWebSocketController")

    static func handleCrudDocumentData(userId: String, data: Data, db: Database) async {
        do {

            let message = try JSONDecoder().decode(AnnotatoCrudDocumentMessage.self, from: data)
            let document = message.document

            switch message.subtype {
            case .createDocument:
                await Self.handleCreateDocument(userId: userId, db: db, document: document)
            case .readDocument:
                await Self.handleReadDocument(userId: userId, db: db, document: document)
            case .updateDocument:
                await Self.handleUpdateDocument(userId: userId, db: db, document: document)
            case .deleteDocument:
                await Self.handleDeleteDocument(userId: userId, db: db, document: document)
            }

        } catch {
            Self.logger.error("Error when handling incoming crud document data. \(error.localizedDescription)")
        }
    }

    private static func handleCreateDocument(userId: String, db: Database, document: Document) async {
        do {

            let newDocument = try await DocumentsDataAccess.create(db: db, document: document)
            let response = AnnotatoCrudDocumentMessage(subtype: .createDocument, document: newDocument)

            await Self.sendToAllAppropriateClients(
                db: db, userId: userId, document: newDocument, message: response
            )

        } catch {
            Self.logger.error("Error when creating document. \(error.localizedDescription)")
        }
    }

    private static func handleReadDocument(userId: String, db: Database, document: Document) async {
        do {

            let readDocument = try await DocumentsDataAccess.read(db: db, documentId: document.id)
            let response = AnnotatoCrudDocumentMessage(subtype: .readDocument, document: readDocument)

            await Self.sendToAllAppropriateClients(
                db: db, userId: userId, document: readDocument, message: response
            )

        } catch {
            Self.logger.error("Error when reading document. \(error.localizedDescription)")
        }
    }

    private static func handleUpdateDocument(userId: String, db: Database, document: Document) async {
        do {

            let updatedDocument = try await DocumentsDataAccess
                .update(db: db, documentId: document.id, document: document)
            let response = AnnotatoCrudDocumentMessage(subtype: .updateDocument, document: updatedDocument)

            await Self.sendToAllAppropriateClients(
                db: db, userId: userId, document: updatedDocument, message: response
            )
        } catch {
            Self.logger.error("Error when updating document. \(error.localizedDescription)")
        }
    }

    private static func handleDeleteDocument(userId: String, db: Database, document: Document) async {
        do {

            let deletedDocument = try await DocumentsDataAccess.delete(db: db, documentId: document.id)
            let response = AnnotatoCrudDocumentMessage(subtype: .deleteDocument, document: deletedDocument)

            await Self.sendToAllAppropriateClients(
                db: db, userId: userId, document: deletedDocument, message: response
            )

        } catch {
            Self.logger.error("Error when deleting document. \(error.localizedDescription)")
        }
    }

    private static func sendToAllAppropriateClients<T: Codable>(
        db: Database,
        userId: String,
        document: Document,
        message: T
    ) async {
        do {
            let documentShares = try await DocumentSharesDataAccess
                .findAllRecipientsUsingDocumentId(db: db, documentId: document.id)

            // Gets the users sharing document
            var recipientIdsSet = Set(documentShares.map { $0.recipientId })

            // Adds the document owner
            recipientIdsSet.insert(document.ownerId)

            // Remove the message sender
            recipientIdsSet.remove(userId)

            WebSocketController.sendAll(recipientIds: recipientIdsSet, message: message)
        } catch {
            Self.logger.error("Error when sending response to users. \(error.localizedDescription)")
        }
    }
}
