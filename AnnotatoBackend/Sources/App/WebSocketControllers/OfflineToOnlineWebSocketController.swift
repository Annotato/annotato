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

            let responseDocuments: [Document] = try await DocumentWebSocketController
                .handleOverrideServerDocuments(userId: userId, db: db, documents: message.documents)

            let responseAnnotations: [Annotation] = try await AnnotationWebSocketController
                .handleOverrideServerAnnotations(userId: userId, db: db, annotations: message.annotations)

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

    private static func sendBackToSender<T: Codable>(userId: String, message: T) async {
        Self.logger.info("Sending offline to online resolution back to sender...")

        WebSocketController.sendAll(recipientIds: [userId], message: message)
    }
}
