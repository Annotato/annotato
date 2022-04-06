import Foundation
import Vapor
import AnnotatoSharedLibrary
import FluentKit

class DocumentWebSocketController {
    private static var logger = Logger(label: "DocumentWebSocketController")

    static func handleCrudDocumentData(userId: String, data: Data, db: Database) async {
        do {
            Self.logger.info("Processing crud document data...")

            let message = try JSONCustomDecoder().decode(AnnotatoCudDocumentMessage.self, from: data)
            let document = message.document

            switch message.subtype {
            case .createDocument:
                _ = await Self.handleCreateDocument(userId: userId, db: db, document: document)
            case .updateDocument:
                _ = await Self.handleUpdateDocument(userId: userId, db: db, document: document)
            case .deleteDocument:
                _ = await Self.handleDeleteDocument(userId: userId, db: db, document: document)
            }
        } catch {
            Self.logger.error("Error when handling incoming crud document data. \(error.localizedDescription)")
        }
    }

    private static func handleCreateDocument(userId: String, db: Database, document: Document) async -> Document? {
        do {
            Self.logger.info("Processing create document data...")

            let newDocument = try await DocumentsDataAccess.create(db: db, document: document)
            let response = AnnotatoCudDocumentMessage(subtype: .createDocument, document: newDocument)

            await Self.sendToAllAppropriateClients(
                db: db, userId: userId, document: newDocument, message: response
            )

            return newDocument
        } catch {
            Self.logger.error("Error when creating document. \(error.localizedDescription)")
            return nil
        }
    }

    private static func handleUpdateDocument(userId: String, db: Database, document: Document) async -> Document? {
        do {
            Self.logger.info("Processing update document data...")

            let updatedDocument = try await DocumentsDataAccess
                .update(db: db, documentId: document.id, document: document)
            let response = AnnotatoCudDocumentMessage(subtype: .updateDocument, document: updatedDocument)

            await Self.sendToAllAppropriateClients(
                db: db, userId: userId, document: updatedDocument, message: response
            )

            return updatedDocument
        } catch {
            Self.logger.error("Error when updating document. \(error.localizedDescription)")
            return nil
        }
    }

    private static func handleDeleteDocument(userId: String, db: Database, document: Document) async -> Document? {
        do {
            Self.logger.info("Processing delete document data...")

            let deletedDocument = try await DocumentsDataAccess.delete(db: db, documentId: document.id)
            let response = AnnotatoCudDocumentMessage(subtype: .deleteDocument, document: deletedDocument)

            await Self.sendToAllAppropriateClients(
                db: db, userId: userId, document: deletedDocument, message: response
            )

            return deletedDocument
        } catch {
            Self.logger.error("Error when deleting document. \(error.localizedDescription)")
            return nil
        }
    }

    static func handleOverrideServerDocuments(
        userId: String,
        db: Database,
        message: AnnotatoOfflineToOnlineMessage
    ) async throws -> [Document] {
        var responseDocuments: [Document] = []

        for document in message.documents {
            let resolvedDocument: Document?

            if document.isDeleted {
                resolvedDocument = await Self.handleDeleteDocument(userId: userId, db: db, document: document)
            } else if await DocumentsDataAccess.canFindWithDeleted(db: db, documentId: document.id) {
                resolvedDocument = await Self.handleUpdateDocument(userId: userId, db: db, document: document)
            } else {
                resolvedDocument = await Self.handleCreateDocument(userId: userId, db: db, document: document)
            }

            responseDocuments.appendIfNotNil(resolvedDocument)
        }

        let newServerDocumentsWhileOffline = try await DocumentsDataAccess
            .listEntitiesCreatedAfterDateWithDeleted(db: db, date: message.lastOnlineAt, userId: userId)

        for document in newServerDocumentsWhileOffline {
            _ = await Self.handleDeleteDocument(userId: userId, db: db, document: document)
        }

        return responseDocuments
    }

    private static func sendToAllAppropriateClients<T: Codable>(
        db: Database,
        userId: String,
        document: Document,
        message: T
    ) async {
        do {
            Self.logger.info("Sending document messages to appropriate connected clients...")

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
