import Foundation
import Vapor
import AnnotatoSharedLibrary
import FluentKit

class AnnotationWebSocketController {
    private static var logger = Logger(label: "AnnotationWebSocketController")

    static func handleCrudAnnotationData(userId: String, data: Data, db: Database) async {
        do {
            Self.logger.info("Processing crud annotation data...")

            let message = try JSONCustomDecoder().decode(AnnotatoCudAnnotationMessage.self, from: data)
            let annotation = message.annotation

            switch message.subtype {
            case .createAnnotation:
                _ = await Self.handleCreateAnnotation(userId: userId, db: db, annotation: annotation)
            case .updateAnnotation:
                _ = await Self.handleUpdateAnnotation(userId: userId, db: db, annotation: annotation)
            case .deleteAnnotation:
                _ = await Self.handleDeleteAnnotation(userId: userId, db: db, annotation: annotation)
            }

        } catch {
            Self.logger.error("Error when handling incoming crud annotation data. \(error.localizedDescription)")
        }
    }

    private static func handleCreateAnnotation(
        userId: String,
        db: Database,
        annotation: Annotation
    ) async -> Annotation? {
        do {
            Self.logger.info("Processing create annotation data...")

            let newAnnotation = try await AnnotationDataAccess.create(db: db, annotation: annotation)
            let response = AnnotatoCudAnnotationMessage(subtype: .createAnnotation, annotation: newAnnotation)

            await Self.sendToAllAppropriateClients(
                db: db, userId: userId, annotation: newAnnotation, message: response
            )

            return newAnnotation
        } catch {
            Self.logger.error("Error when creating annotation. \(error.localizedDescription)")
            return nil
        }
    }

    private static func handleUpdateAnnotation(
        userId: String,
        db: Database,
        annotation: Annotation
    ) async -> Annotation? {
        do {
            Self.logger.info("Processing update annotation data...")

            let updatedAnnotation = try await AnnotationDataAccess
                .update(db: db, annotationId: annotation.id, annotation: annotation)
            let response = AnnotatoCudAnnotationMessage(subtype: .updateAnnotation, annotation: updatedAnnotation)

            await Self.sendToAllAppropriateClients(
                db: db, userId: userId, annotation: updatedAnnotation, message: response
            )

            return updatedAnnotation
        } catch {
            Self.logger.error("Error when updating annotation. \(error.localizedDescription)")
            return nil
        }
    }

    private static func handleDeleteAnnotation(
        userId: String,
        db: Database,
        annotation: Annotation
    ) async -> Annotation? {
        do {
            Self.logger.info("Processing delete annotation data...")

            let deletedAnnotation = try await AnnotationDataAccess.delete(db: db, annotationId: annotation.id)
            let response = AnnotatoCudAnnotationMessage(subtype: .deleteAnnotation, annotation: deletedAnnotation)

            await Self.sendToAllAppropriateClients(
                db: db, userId: userId, annotation: deletedAnnotation, message: response
            )

            return deletedAnnotation
        } catch {
            Self.logger.error("Error when deleting annotation. \(error.localizedDescription)")
            return nil
        }
    }

    static func handleOverrideServerAnnotations(
        userId: String,
        db: Database,
        message: AnnotatoOfflineToOnlineMessage
    ) async throws -> [Annotation] {
        var responseAnnotations: [Annotation] = []

        for annotation in message.annotations {
            let resolvedAnnotation: Annotation?

            if annotation.isDeleted {
                resolvedAnnotation = await Self.handleDeleteAnnotation(userId: userId, db: db, annotation: annotation)
            } else if await AnnotationDataAccess.canFindWithDeleted(db: db, annotationId: annotation.id) {
                resolvedAnnotation = await Self.handleUpdateAnnotation(userId: userId, db: db, annotation: annotation)
            } else {
                resolvedAnnotation = await Self.handleCreateAnnotation(userId: userId, db: db, annotation: annotation)
            }

            responseAnnotations.appendIfNotNil(resolvedAnnotation)
        }

        let newServerAnnotationsWhileOffline = try await AnnotationDataAccess
            .listEntitiesCreatedAfterDateWithDeleted(db: db, date: message.lastOnlineAt, userId: userId)

        for annotation in newServerAnnotationsWhileOffline {
            _ = await Self.handleDeleteAnnotation(userId: userId, db: db, annotation: annotation)
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
