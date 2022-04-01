import Foundation
import Vapor
import AnnotatoSharedLibrary
import FluentKit

class OfflineToOnlineWebSocketController {
    private static var logger = Logger(label: "OfflineToOnlineWebSocketController")

    static func handleOfflineToOnlineResolution(userId: String, data: Data, db: Database) async {
        do {
            Self.logger.info("Processing offline to online data...")

            let message = try JSONCustomDecoder().decode(AnnotatoOfflineToOnlineMessage.self, from: data)

            switch message.mergeStrategy {
            case .duplicateConflicts:
                print("duplicate conflicts")
            case .keepServerVersion:
                print("keep server version")
            case .overrideServerVersion:
                await Self.handleOverrideServerVersion(userId: userId, db: db, message: message)
            }
        } catch {
            print(String(describing: error))
            Self.logger.error("Error when handling incoming offline to online data. \(error.localizedDescription)")
        }
    }

    private static func handleOverrideServerVersion(
        userId: String,
        db: Database,
        message: AnnotatoOfflineToOnlineMessage
    ) async {
        do {
            Self.logger.info("Processing override server data...")

            let responseDocuments: [Document] = try await handleOverrideServerDocuments(
                userId: userId, db: db, documents: message.documents)

            let responseAnnotations: [Annotation] = try await handleOverrideServerAnnotations(
                userId: userId, db: db, annotations: message.annotations)

            let response = AnnotatoOfflineToOnlineMessage(
                mergeStrategy: .overrideServerVersion,
                documents: responseDocuments,
                annotations: responseAnnotations
            )

            await Self.sendBackToSender(userId: userId, message: response)
        } catch {
            Self.logger.error("Error when overriding server version. \(error.localizedDescription)")
        }
    }

    private static func handleOverrideServerDocuments(
        userId: String, db: Database, documents: [Document]) async throws -> [Document] {
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

            await DocumentWebSocketController.sendToAllAppropriateClients(
                db: db, userId: userId, document: resolvedDocument, message: responseToOtherClients
            )
            responseDocuments.append(resolvedDocument)
        }
        return responseDocuments
    }

    private static func handleOverrideServerAnnotations(
        userId: String, db: Database, annotations: [Annotation]) async throws -> [Annotation] {
        var responseAnnotations: [Annotation] = []

        for annotation in annotations {
            let resolvedAnnotation: Annotation
            let responseToOtherClients: AnnotatoCrudAnnotationMessage

            if annotation.isDeleted {
                resolvedAnnotation = try await AnnotationDataAccess.delete(
                    db: db, annotationId: annotation.id)
                responseToOtherClients = AnnotatoCrudAnnotationMessage(
                    subtype: .deleteAnnotation, annotation: resolvedAnnotation)
            } else if await AnnotationDataAccess.canFindWithDeleted(db: db, annotationId: annotation.id) {
                resolvedAnnotation = try await AnnotationDataAccess.update(
                    db: db, annotationId: annotation.id, annotation: annotation)
                responseToOtherClients = AnnotatoCrudAnnotationMessage(
                    subtype: .updateAnnotation, annotation: resolvedAnnotation)
            } else {
                resolvedAnnotation = try await AnnotationDataAccess.create(db: db, annotation: annotation)
                responseToOtherClients = AnnotatoCrudAnnotationMessage(
                    subtype: .createAnnotation, annotation: resolvedAnnotation)
            }

            await AnnotationWebSocketController.sendToAllAppropriateClients(
                db: db, userId: userId, annotation: resolvedAnnotation, message: responseToOtherClients
            )
            responseAnnotations.append(resolvedAnnotation)
        }

        return responseAnnotations
    }

    private static func sendBackToSender<T: Codable>(userId: String, message: T) async {
        do {
            Self.logger.info("Sending offline to online resolution back to sender...")

            WebSocketController.sendAll(recipientIds: [userId], message: message)
        } catch {
            Self.logger.error("Error when sending response to users. \(error.localizedDescription)")
        }
    }
}
