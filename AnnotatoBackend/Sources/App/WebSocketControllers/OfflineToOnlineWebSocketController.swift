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
            case .keepServerVersion:
                await handleKeepServerVersion(userId: userId, db: db, message: message)
            case .overrideServerVersion:
                await Self.handleOverrideServerVersion(userId: userId, db: db, message: message)
            }
        } catch {
            Self.logger.error("Error when handling incoming offline to online data. \(error.localizedDescription)")
        }
    }

    private static func handleKeepServerVersion(
        userId: String,
        db: Database,
        message: AnnotatoOfflineToOnlineMessage
    ) async {
        do {
            let updatedServerDocuments = try await DocumentsDataAccess
                .listEntitiesUpdatedAfterDateWithDeleted(db: db, date: message.lastOnlineAt, userId: userId)

            let serverVersionOfUserDocuments = try await DocumentsDataAccess
                .listWithDeleted(db: db, documentIds: message.documents.map { $0.id })

            let responseDocuments = Array(Set(updatedServerDocuments).union(Set(serverVersionOfUserDocuments)))

            let updatedServerAnnotations = try await AnnotationDataAccess
                .listEntitiesUpdatedAfterDateWithDeleted(db: db, date: message.lastOnlineAt, userId: userId)

            let serverVersionOfUserAnnotations = try await AnnotationDataAccess
                .listWithDeleted(db: db, annotationIds: message.annotations.map { $0.id })

            let responseAnnotations = Array(Set(updatedServerAnnotations).union(Set(serverVersionOfUserAnnotations)))

            let response = AnnotatoOfflineToOnlineMessage(
                senderId: userId,
                mergeStrategy: .keepServerVersion,
                lastOnlineAt: message.lastOnlineAt,
                documents: responseDocuments,
                annotations: responseAnnotations
            )

            await Self.sendBackToSender(userId: userId, message: response)
        } catch {
            Self.logger.error("Error when keeping server data. \(error.localizedDescription)")
        }
    }

    private static func handleOverrideServerVersion(
        userId: String,
        db: Database,
        message: AnnotatoOfflineToOnlineMessage
    ) async {
        do {
            Self.logger.info("Processing override server data...")

            let responseDocuments = try await DocumentWebSocketController
                .handleOverrideServerDocuments(userId: userId, db: db, message: message)

            let responseAnnotations = try await AnnotationWebSocketController
                .handleOverrideServerAnnotations(userId: userId, db: db, message: message)

            let response = AnnotatoOfflineToOnlineMessage(
                senderId: userId, 
                mergeStrategy: .overrideServerVersion,
                lastOnlineAt: message.lastOnlineAt,
                documents: responseDocuments,
                annotations: responseAnnotations
            )

            await Self.sendBackToSender(userId: userId, message: response)
        } catch {
            Self.logger.error("Error when overriding server data. \(error.localizedDescription)")
        }
    }

    private static func sendBackToSender<T: Codable>(userId: String, message: T) async {
        Self.logger.info("Sending offline to online resolution back to sender...")

        WebSocketController.sendAll(recipientIds: [userId], message: message)
    }
}
