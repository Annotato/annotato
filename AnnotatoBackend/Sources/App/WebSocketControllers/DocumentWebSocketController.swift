import Foundation
import Vapor
import AnnotatoSharedLibrary
import FluentKit

class DocumentWebSocketController {
    private weak var parentController: WebSocketController?

    private let documentsDataAccess = DocumentsDataAccess()
    private let documentSharesDataAccess = DocumentSharesDataAccess()

    private let logger = Logger(label: "DocumentWebSocketController")

    init(parentController: WebSocketController) {
        self.parentController = parentController
    }

    func handleCrudDocumentData(userId: String, data: Data, db: Database) async {
        do {
            self.logger.info("Processing crud document data...")

            let message = try JSONCustomDecoder().decode(AnnotatoCudDocumentMessage.self, from: data)
            let document = message.document

            switch message.subtype {
            case .createDocument:
                _ = await self.handleCreateDocument(userId: userId, db: db, document: document)
            case .updateDocument:
                _ = await self.handleUpdateDocument(userId: userId, db: db, document: document)
            case .deleteDocument:
                _ = await self.handleDeleteDocument(userId: userId, db: db, document: document)
            }
        } catch {
            self.logger.error("Error when handling incoming crud document data. \(error.localizedDescription)")
        }
    }

    private func handleCreateDocument(userId: String, db: Database, document: Document) async -> Document? {
        do {
            self.logger.info("Processing create document data...")

            let newDocument = try await documentsDataAccess.create(db: db, document: document)
            let response = AnnotatoCudDocumentMessage(
                senderId: userId, subtype: .createDocument, document: newDocument
            )

            await self.sendToAllAppropriateClients(
                db: db, userId: userId, document: newDocument, message: response
            )

            return newDocument
        } catch {
            self.logger.error("Error when creating document. \(error.localizedDescription)")
            return nil
        }
    }

    private func handleUpdateDocument(userId: String, db: Database, document: Document) async -> Document? {
        do {
            self.logger.info("Processing update document data...")

            let updatedDocument = try await documentsDataAccess
                .update(db: db, documentId: document.id, document: document)
            let response = AnnotatoCudDocumentMessage(
                senderId: userId, subtype: .updateDocument, document: updatedDocument
            )

            await self.sendToAllAppropriateClients(
                db: db, userId: userId, document: updatedDocument, message: response
            )

            return updatedDocument
        } catch {
            self.logger.error("Error when updating document. \(error.localizedDescription)")
            return nil
        }
    }

    private func handleDeleteDocument(userId: String, db: Database, document: Document) async -> Document? {
        do {
            self.logger.info("Processing delete document data...")

            let deletedDocument = try await documentsDataAccess.delete(db: db, documentId: document.id)
            let response = AnnotatoCudDocumentMessage(
                senderId: userId, subtype: .deleteDocument, document: deletedDocument
            )

            await self.sendToAllAppropriateClients(
                db: db, userId: userId, document: deletedDocument, message: response
            )

            return deletedDocument
        } catch {
            self.logger.error("Error when deleting document. \(error.localizedDescription)")
            return nil
        }
    }

    private func sendToAllAppropriateClients<T: Codable>(
        db: Database,
        userId: String,
        document: Document,
        message: T
    ) async {
        do {
            self.logger.info("Sending document messages to appropriate connected clients...")

            let documentShares = try await documentSharesDataAccess
                .findAllRecipientsUsingDocumentId(db: db, documentId: document.id)

            // Gets the users sharing document
            var recipientIdsSet = Set(documentShares.map { $0.recipientId })

            // Adds the document owner
            recipientIdsSet.insert(document.ownerId)

            parentController?.sendAll(recipientIds: recipientIdsSet, message: message)
        } catch {
            self.logger.error("Error when sending response to users. \(error.localizedDescription)")
        }
    }
}
