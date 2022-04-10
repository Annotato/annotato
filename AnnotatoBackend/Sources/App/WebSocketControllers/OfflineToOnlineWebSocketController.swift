import Foundation
import Vapor
import AnnotatoSharedLibrary
import FluentKit

class OfflineToOnlineWebSocketController {
    private weak var parentController: WebSocketController?

    private let documentsDataAccess = DocumentsDataAccess()
    private let annotationDataAccess = AnnotationDataAccess()

    private let logger = Logger(label: "OfflineToOnlineWebSocketController")

    init(parentController: WebSocketController) {
        self.parentController = parentController
    }

    func handleOfflineToOnlineResolution(userId: String, data: Data, db: Database) async {
        do {
            self.logger.info("Processing offline to online data...")

            let message = try JSONCustomDecoder().decode(AnnotatoOfflineToOnlineMessage.self, from: data)

            switch message.mergeStrategy {
            case .keepServerVersion:
                await self.handleKeepServerVersion(userId: userId, db: db, message: message)
            case .overrideServerVersion:
                await self.handleOverrideServerVersion(userId: userId, db: db, message: message)
            }
        } catch {
            self.logger.error("Error when handling incoming offline to online data. \(error.localizedDescription)")
        }
    }

    func handleKeepServerVersion(
        userId: String,
        db: Database,
        message: AnnotatoOfflineToOnlineMessage
    ) async {
        do {
            let updatedServerDocuments = try await documentsDataAccess
                .listEntitiesUpdatedAfterDateWithDeleted(db: db, date: message.lastOnlineAt, userId: userId)

            let serverVersionOfUserDocuments = try await documentsDataAccess
                .listWithDeleted(db: db, documentIds: message.documents.map { $0.id })

            let responseDocuments = Array(Set(updatedServerDocuments).union(Set(serverVersionOfUserDocuments)))

            let updatedServerAnnotations = try await annotationDataAccess
                .listEntitiesUpdatedAfterDateWithDeleted(db: db, date: message.lastOnlineAt, userId: userId)

            let serverVersionOfUserAnnotations = try await annotationDataAccess
                .listWithDeleted(db: db, annotationIds: message.annotations.map { $0.id })

            let responseAnnotations = Array(Set(updatedServerAnnotations).union(Set(serverVersionOfUserAnnotations)))

            let response = AnnotatoOfflineToOnlineMessage(
                senderId: userId,
                mergeStrategy: .keepServerVersion,
                lastOnlineAt: message.lastOnlineAt,
                documents: responseDocuments,
                annotations: responseAnnotations
            )

            await self.sendBackToSender(userId: userId, message: response)
        } catch {
            self.logger.error("Error when keeping server data. \(error.localizedDescription)")
        }
    }

    func handleOverrideServerVersion(
        userId: String,
        db: Database,
        message: AnnotatoOfflineToOnlineMessage
    ) async {
        do {
            self.logger.info("Processing override server data...")

            let responseDocuments = try await parentController?.documentWebSocketController
                .handleOverrideServerDocuments(userId: userId, db: db, message: message)

            let responseAnnotations = try await parentController?.annotationWebSocketController
                .handleOverrideServerAnnotations(userId: userId, db: db, message: message)

            let response = AnnotatoOfflineToOnlineMessage(
                senderId: userId,
                mergeStrategy: .overrideServerVersion,
                lastOnlineAt: message.lastOnlineAt,
                documents: responseDocuments ?? [],
                annotations: responseAnnotations ?? []
            )

            await self.sendBackToSender(userId: userId, message: response)
        } catch {
            self.logger.error("Error when overriding server data. \(error.localizedDescription)")
        }
    }

    func sendBackToSender<T: Codable>(userId: String, message: T) async {
        self.logger.info("Sending offline to online resolution back to sender...")

        parentController?.sendAll(recipientIds: [userId], message: message)
    }
}
