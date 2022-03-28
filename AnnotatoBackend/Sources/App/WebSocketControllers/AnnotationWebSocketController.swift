import Foundation
import Vapor
import AnnotatoSharedLibrary
import FluentKit

class AnnotationWebSocketController {
    private static var logger = Logger(label: "AnnotationWebSocketController")

    static func handleCrudAnnotationData(userId: String, ws: WebSocket, data: Data, db: Database) async {
        do {

            let message = try JSONDecoder().decode(AnnotatoCrudAnnotationMessage.self, from: data)

            switch message.subtype {
            case .createAnnotation:
                await Self.handleCreateAnnotation(userId: userId, ws: ws, db: db, annotation: message.annotation)
            case .readAnnotation:
                await Self.handleReadAnnotation(userId: userId, ws: ws, db: db, annotation: message.annotation)
            case .updateAnnotation:
                await Self.handleUpdateAnnotation(userId: userId, ws: ws, db: db, annotation: message.annotation)
            case .deleteAnnotation:
                await Self.handleDeleteAnnotation(userId: userId, ws: ws, db: db, annotation: message.annotation)
            }

        } catch {
            Self.logger.error("Error when handling incoming crud annotation data. \(error.localizedDescription)")
        }
    }

    private static func handleCreateAnnotation(
        userId: String,
        ws: WebSocket,
        db: Database,
        annotation: Annotation
    ) async {
        do {

            let newAnnotation = try await AnnotationDataAccess.create(db: db, annotation: annotation)
            let response = AnnotatoCrudAnnotationMessage(subtype: .createAnnotation, annotation: newAnnotation)

            await WebSocketController
                .sendToAllAppropriateClients(
                    userId: userId, documentId: newAnnotation.documentId, db: db, message: response
                )

        } catch {
            Self.logger.error("Error when creating annotation. \(error.localizedDescription)")
        }
    }

    private static func handleReadAnnotation(
        userId: String,
        ws: WebSocket,
        db: Database,
        annotation: Annotation
    ) async {
        do {

            let readAnnotation = try await AnnotationDataAccess.read(db: db, annotationId: annotation.id)
            let response = AnnotatoCrudAnnotationMessage(subtype: .readAnnotation, annotation: readAnnotation)

            await WebSocketController
                .sendToAllAppropriateClients(
                    userId: userId, documentId: readAnnotation.documentId, db: db, message: response
                )

        } catch {
            Self.logger.error("Error when reading annotation. \(error.localizedDescription)")
        }
    }

    private static func handleUpdateAnnotation(
        userId: String,
        ws: WebSocket,
        db: Database,
        annotation: Annotation
    ) async {
        do {

            let updatedAnnotation = try await AnnotationDataAccess
                .update(db: db, annotationId: annotation.id, annotation: annotation)
            let response = AnnotatoCrudAnnotationMessage(subtype: .updateAnnotation, annotation: updatedAnnotation)

            await WebSocketController
                .sendToAllAppropriateClients(
                    userId: userId, documentId: updatedAnnotation.documentId, db: db, message: response
                )

        } catch {
            Self.logger.error("Error when updating annotation. \(error.localizedDescription)")
        }
    }

    private static func handleDeleteAnnotation(
        userId: String, ws: WebSocket,
        db: Database,
        annotation: Annotation
    ) async {
        do {

            let deletedAnnotation = try await AnnotationDataAccess.delete(db: db, annotationId: annotation.id)
            let response = AnnotatoCrudAnnotationMessage(subtype: .deleteAnnotation, annotation: deletedAnnotation)

            await WebSocketController
                .sendToAllAppropriateClients(
                    userId: userId, documentId: deletedAnnotation.documentId, db: db, message: response
                )

        } catch {
            Self.logger.error("Error when deleting annotation. \(error.localizedDescription)")
        }
    }
}
