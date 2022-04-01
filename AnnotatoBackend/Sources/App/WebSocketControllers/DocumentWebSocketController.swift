import Foundation
import Vapor
import AnnotatoSharedLibrary
import FluentKit

class DocumentWebSocketController {
    private static var logger = Logger(label: "DocumentWebSocketController")

    static func handleCrudDocumentData(userId: String, data: Data, db: Database) async {
        do {
            Self.logger.info("Processing crud document data...")

            let message = try JSONCustomDecoder().decode(AnnotatoCrudDocumentMessage.self, from: data)
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
            Self.logger.info("Processing create document data...")

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
            Self.logger.info("Processing read document data...")

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
            Self.logger.info("Processing update document data...")

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
            Self.logger.info("Processing delete document data...")

            let deletedDocument = try await DocumentsDataAccess.delete(db: db, documentId: document.id)
            let response = AnnotatoCrudDocumentMessage(subtype: .deleteDocument, document: deletedDocument)

            await Self.sendToAllAppropriateClients(
                db: db, userId: userId, document: deletedDocument, message: response
            )

        } catch {
            Self.logger.error("Error when deleting document. \(error.localizedDescription)")
        }
    }

    static func handleOverrideServerDocuments(
        userId: String, db: Database, documents: [Document]
    ) async throws -> [Document] {
        var responseDocuments: [Document] = []

        for document in documents {
            let resolvedDocument: Document
            let responseToOtherClients: AnnotatoCrudDocumentMessage

            if document.isDeleted {
                resolvedDocument = try await DocumentsDataAccess.delete(
                    db: db, documentId: document.id)
                responseToOtherClients = AnnotatoCrudDocumentMessage(
                    subtype: .deleteDocument, document: resolvedDocument)
            } else if await DocumentsDataAccess.canFindWithDeleted(db: db, documentId: document.id) {
                resolvedDocument = try await DocumentsDataAccess.update(
                    db: db, documentId: document.id, document: document)
                responseToOtherClients = AnnotatoCrudDocumentMessage(
                    subtype: .updateDocument, document: resolvedDocument)
            } else {
                resolvedDocument = try await DocumentsDataAccess.create(db: db, document: document)
                responseToOtherClients = AnnotatoCrudDocumentMessage(
                    subtype: .createDocument, document: resolvedDocument)
            }

            await Self.sendToAllAppropriateClients(
                db: db, userId: userId, document: resolvedDocument, message: responseToOtherClients
            )
            responseDocuments.append(resolvedDocument)
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
