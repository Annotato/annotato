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
                print("override server version")
            }
        } catch {
            Self.logger.error("Error when handling incoming offline to online data. \(error.localizedDescription)")
        }
    }
}
