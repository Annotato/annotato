import Foundation
import Vapor
import AnnotatoSharedLibrary
import FluentKit

class AnnotationWebSocketController {
    private weak var parentController: WebSocketController?

    private let annotationDataAccess = AnnotationDataAccess()
    private let documentsDataAccess = DocumentsDataAccess()
    private let documentSharesDataAccess = DocumentSharesDataAccess()

    private let logger = Logger(label: "AnnotationWebSocketController")

    init(parentController: WebSocketController) {
        self.parentController = parentController
    }

    func handleCrudAnnotationData(userId: String, data: Data, db: Database) async {
        do {
            self.logger.info("Processing crud annotation data...")

            let message = try JSONCustomDecoder().decode(AnnotatoCudAnnotationMessage.self, from: data)
            let annotation = message.annotation

            switch message.subtype {
            case .createAnnotation:
                _ = await self.handleCreateAnnotation(userId: userId, db: db, annotation: annotation)
            case .updateAnnotation:
                _ = await self.handleUpdateAnnotation(userId: userId, db: db, annotation: annotation)
            case .deleteAnnotation:
                _ = await self.handleDeleteAnnotation(userId: userId, db: db, annotation: annotation)
            }

        } catch {
            self.logger.error("Error when handling incoming crud annotation data. \(error.localizedDescription)")
        }
    }

    private func handleCreateAnnotation(
        userId: String,
        db: Database,
        annotation: Annotation
    ) async -> Annotation? {
        do {
            self.logger.info("Processing create annotation data...")

            let newAnnotation = try await annotationDataAccess.create(db: db, annotation: annotation)
            let response = AnnotatoCudAnnotationMessage(
                senderId: userId, subtype: .createAnnotation, annotation: newAnnotation
            )

            await self.sendToAllAppropriateClients(
                db: db, userId: userId, annotation: newAnnotation, message: response
            )

            return newAnnotation
        } catch {
            self.logger.error("Error when creating annotation. \(error.localizedDescription)")
            return nil
        }
    }

    private func handleUpdateAnnotation(
        userId: String,
        db: Database,
        annotation: Annotation
    ) async -> Annotation? {
        do {
            self.logger.info("Processing update annotation data...")

            let updatedAnnotation = try await annotationDataAccess
                .update(db: db, annotationId: annotation.id, annotation: annotation)
            let response = AnnotatoCudAnnotationMessage(
                senderId: userId, subtype: .updateAnnotation, annotation: updatedAnnotation
            )

            await self.sendToAllAppropriateClients(
                db: db, userId: userId, annotation: updatedAnnotation, message: response
            )

            return updatedAnnotation
        } catch {
            self.logger.error("Error when updating annotation. \(error.localizedDescription)")
            return nil
        }
    }

    private func handleDeleteAnnotation(
        userId: String,
        db: Database,
        annotation: Annotation
    ) async -> Annotation? {
        do {
            self.logger.info("Processing delete annotation data...")

            let deletedAnnotation = try await annotationDataAccess.delete(db: db, annotationId: annotation.id)
            let response = AnnotatoCudAnnotationMessage(
                senderId: userId, subtype: .deleteAnnotation, annotation: deletedAnnotation
            )

            await self.sendToAllAppropriateClients(
                db: db, userId: userId, annotation: deletedAnnotation, message: response
            )

            return deletedAnnotation
        } catch {
            self.logger.error("Error when deleting annotation. \(error.localizedDescription)")
            return nil
        }
    }

    private func sendToAllAppropriateClients<T: Codable>(
        db: Database,
        userId: String,
        annotation: Annotation,
        message: T
    ) async {
        do {
            self.logger.info("Sending annotation messages to appropriate connected clients...")

            let annotationDocument = try await documentsDataAccess.read(db: db, documentId: annotation.documentId)
            let documentShares = try await documentSharesDataAccess
                .findAllRecipientsUsingDocumentId(db: db, documentId: annotation.documentId)

            // Gets the users sharing document
            var recipientIdsSet = Set(documentShares.map { $0.recipientId })

            // Adds the document owner
            recipientIdsSet.insert(annotationDocument.ownerId)

            parentController?.sendAll(recipientIds: recipientIdsSet, message: message)
        } catch {
            self.logger.error("Error when sending response to users. \(error.localizedDescription)")
        }
    }
}
