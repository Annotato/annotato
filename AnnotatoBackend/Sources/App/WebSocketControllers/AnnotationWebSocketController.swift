import Foundation
import Vapor
import AnnotatoSharedLibrary
import FluentKit

class AnnotationWebSocketController {
    private static var logger = Logger(label: "AnnotationWebSocketController")

    static func handleCrudAnnotationData(userId: String, data: Data, db: Database) async {
        do {
            Self.logger.info("Processing crud annotation data...")

            let message = try JSONCustomDecoder().decode(AnnotatoCrudAnnotationMessage.self, from: data)
            let annotation = message.annotation

            switch message.subtype {
            case .createAnnotation:
                await Self.handleCreateAnnotation(userId: userId, db: db, annotation: annotation)
            case .readAnnotation:
                await Self.handleReadAnnotation(userId: userId, db: db, annotation: annotation)
            case .updateAnnotation:
                await Self.handleUpdateAnnotation(userId: userId, db: db, annotation: annotation)
            case .deleteAnnotation:
                await Self.handleDeleteAnnotation(userId: userId, db: db, annotation: annotation)
            }

        } catch {
            Self.logger.error("Error when handling incoming crud annotation data. \(error.localizedDescription)")
        }
    }

    private static func handleCreateAnnotation(
        userId: String,
        db: Database,
        annotation: Annotation
    ) async {
        do {
            Self.logger.info("Processing create annotation data...")

            let newAnnotation = try await AnnotationDataAccess.create(db: db, annotation: annotation)
            let response = AnnotatoCrudAnnotationMessage(subtype: .createAnnotation, annotation: newAnnotation)

            await Self.sendToAllAppropriateClients(
                db: db, userId: userId, annotation: newAnnotation, message: response
            )

        } catch {
            Self.logger.error("Error when creating annotation. \(error.localizedDescription)")
        }
    }

    private static func handleReadAnnotation(
        userId: String,
        db: Database,
        annotation: Annotation
    ) async {
        do {
            Self.logger.info("Processing read annotation data...")

            let readAnnotation = try await AnnotationDataAccess.read(db: db, annotationId: annotation.id)
            let response = AnnotatoCrudAnnotationMessage(subtype: .readAnnotation, annotation: readAnnotation)

            await Self.sendToAllAppropriateClients(
                db: db, userId: userId, annotation: readAnnotation, message: response
            )

        } catch {
            Self.logger.error("Error when reading annotation. \(error.localizedDescription)")
        }
    }

    private static func handleUpdateAnnotation(
        userId: String,
        db: Database,
        annotation: Annotation
    ) async {
        do {
            Self.logger.info("Processing update annotation data...")

            let updatedAnnotation = try await AnnotationDataAccess
                .update(db: db, annotationId: annotation.id, annotation: annotation)
            let response = AnnotatoCrudAnnotationMessage(subtype: .updateAnnotation, annotation: updatedAnnotation)

            await Self.sendToAllAppropriateClients(
                db: db, userId: userId, annotation: updatedAnnotation, message: response
            )

        } catch {
            Self.logger.error("Error when updating annotation. \(error.localizedDescription)")
        }
    }

    private static func handleDeleteAnnotation(
        userId: String,
        db: Database,
        annotation: Annotation
    ) async {
        do {
            Self.logger.info("Processing delete annotation data...")

            let deletedAnnotation = try await AnnotationDataAccess.delete(db: db, annotationId: annotation.id)
            let response = AnnotatoCrudAnnotationMessage(subtype: .deleteAnnotation, annotation: deletedAnnotation)

            await Self.sendToAllAppropriateClients(
                db: db, userId: userId, annotation: deletedAnnotation, message: response
            )

        } catch {
            Self.logger.error("Error when deleting annotation. \(error.localizedDescription)")
        }
    }

    static func handleOverrideServerAnnotations(
        userId: String, db: Database, annotations: [Annotation]
    ) async throws -> [Annotation] {
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

    private static func sendToAllAppropriateClients<T: Codable>(
        db: Database,
        userId: String,
        annotation: Annotation,
        message: T
    ) async {
        do {
            Self.logger.info("Sending annotation messages to appropriate connected clients...")

            let annotationDocument = try await DocumentsDataAccess.read(db: db, documentId: annotation.documentId)
            let documentShares = try await DocumentSharesDataAccess
                .findAllRecipientsUsingDocumentId(db: db, documentId: annotation.documentId)

            // Gets the users sharing document
            var recipientIdsSet = Set(documentShares.map { $0.recipientId })

            // Adds the document owner
            recipientIdsSet.insert(annotationDocument.ownerId)

            // Remove the message sender
            recipientIdsSet.remove(userId)

            WebSocketController.sendAll(recipientIds: recipientIdsSet, message: message)
        } catch {
            Self.logger.error("Error when sending response to users. \(error.localizedDescription)")
        }
    }
}
