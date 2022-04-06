import Foundation
import AnnotatoSharedLibrary

class OfflineToOnlineWebSocketManager {
    func handleResponseData(data: Data) {
        do {
            AnnotatoLogger.info("Handling offline to online response data...")
            let message = try JSONCustomDecoder().decode(AnnotatoOfflineToOnlineMessage.self, from: data)

            let documents = message.documents
            let annotations = message.annotations

            Task {
                _ = await LocalPersistenceManager.shared.documents
                    .createOrUpdateDocuments(documents: documents)
                _ = await LocalPersistenceManager.shared.annotations
                    .createOrUpdateAnnotations(annotations: annotations)
            }
        } catch {
            AnnotatoLogger.error("When handling response data. \(error.localizedDescription)",
                                 context: "OfflineToOnlineWebSocketManager::handleResponseData")
        }
    }
}
