import Foundation
import Vapor
import AnnotatoSharedLibrary
import FluentKit

class AnnotationWebSocketController {
    private static var logger = Logger(label: "AnnotationWebSocketController")

    static func handleCrudAnnotationData(userId: String, data: Data, db: Database) async {
        do {

            let message = try JSONDecoder().decode(AnnotatoCrudAnnotationMessage.self, from: data)
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

            let newAnnotation = try await AnnotationDataAccess.create(db: db, annotation: annotation)
            let response = AnnotatoCrudAnnotationMessage(subtype: .createAnnotation, annotation: newAnnotation)

            await Self.sendToAllAppropriateClients(
                    userId: userId, documentId: newAnnotation.documentId, db: db, message: response
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

            let readAnnotation = try await AnnotationDataAccess.read(db: db, annotationId: annotation.id)
            let response = AnnotatoCrudAnnotationMessage(subtype: .readAnnotation, annotation: readAnnotation)

            await Self.sendToAllAppropriateClients(
                    userId: userId, documentId: readAnnotation.documentId, db: db, message: response
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

            let updatedAnnotation = try await AnnotationDataAccess
                .update(db: db, annotationId: annotation.id, annotation: annotation)
            let response = AnnotatoCrudAnnotationMessage(subtype: .updateAnnotation, annotation: updatedAnnotation)

            await Self.sendToAllAppropriateClients(
                    userId: userId, documentId: updatedAnnotation.documentId, db: db, message: response
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

            let deletedAnnotation = try await AnnotationDataAccess.delete(db: db, annotationId: annotation.id)
            let response = AnnotatoCrudAnnotationMessage(subtype: .deleteAnnotation, annotation: deletedAnnotation)

            await Self.sendToAllAppropriateClients(
                    userId: userId, documentId: deletedAnnotation.documentId, db: db, message: response
                )

        } catch {
            Self.logger.error("Error when deleting annotation. \(error.localizedDescription)")
        }
    }

    private static func sendToAllAppropriateClients<T: Codable>(userId: String, documentId: UUID, db: Database, message: T) async {
        do {
            let documentShares = try await DocumentSharesDataAccess
                .findAllRecipientsUsingDocumentId(db: db, documentId: documentId)

            // Gets the users sharing document
            var recipientIdsSet = Set(documentShares.map { $0.recipientId })

            // Adds the user that sent the websocket message
            recipientIdsSet.insert(userId)

            WebSocketController.sendAll(recipientIds: recipientIdsSet, message: message)
        } catch {
            Self.logger.error("Error when sending response to users. \(error.localizedDescription)")
        }
    }
}
