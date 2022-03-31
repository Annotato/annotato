import Foundation
import Vapor
import AnnotatoSharedLibrary
import FluentKit

class OfflineToOnlineWebSocketController {
    private static var logger = Logger(label: "OfflineToOnlineWebSocketController")

    static func handleOfflineToOnlineResolution(userId: String, data: Data, db: Database) async {
        do {
            Self.logger.info("Processing offline to online data...")

            let message = try JSONDecoder().decode(AnnotatoOfflineToOnlineMessage.self, from: data)

            switch message.mergeStrategy {
            case .duplicateConflicts:
                print("duplicate conflicts")
            case .keepServerVersion:
                print("keep server version")
            case .overrideServerVersion:
                await Self.handleOverrideServerVersion(userId: userId, db: db, message: message)
            }
        } catch {
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

            let documents = message.documents
            var responseDocuments: [Document] = []

            for document in documents {
                if await DocumentsDataAccess.isFoundIncludingDeleted(db: db, documentId: document.id) {
                    // TODO: Restore/Update deleted at after payload includes it
                    let updatedDocument = try await DocumentsDataAccess.update(
                        db: db, documentId: document.id, document: document)
                    responseDocuments.append(updatedDocument)
                } else {
                    let newDocument = try await DocumentsDataAccess.create(db: db, document: document)
                    responseDocuments.append(newDocument)
                }
            }
        } catch {
            Self.logger.error("Error when overriding server version. \(error.localizedDescription)")
        }
    }
}
