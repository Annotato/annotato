import Foundation
import AnnotatoSharedLibrary

class OfflineToOnlineWebSocketManager {
    func handleResponseData(data: Data) {
        do {
            AnnotatoLogger.info("Handling offline to online response data...")
            let message = try JSONCustomDecoder().decode(AnnotatoOfflineToOnlineMessage.self, from: data)
            let documents = message.documents
            let annotations = message.annotations

            AnnotatoPersistenceWrapper.currentPersistenceService.fastForwardLocalDocuments(documents: documents)
            AnnotatoPersistenceWrapper.currentPersistenceService.fastForwardLocalAnnotations(annotations: annotations)
        } catch {
            AnnotatoLogger.error("When handling response data. \(error.localizedDescription)",
                                 context: "OfflineToOnlineWebSocketManager::handleResponseData")
        }
    }
}
