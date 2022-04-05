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

    func sendOnlineMessage(mergeStrategy: AnnotatoOfflineToOnlineMergeStrategy) {
        guard let lastOnlineDatetime = NetworkMonitor.shared.getLastOnlineDatetime() else {
            return
        }

        let documents = LocalPersistenceManager.shared
            .fetchDocumentsUpdatedAfterDate(date: lastOnlineDatetime) ?? []
        let annotations = LocalPersistenceManager.shared
            .fetchAnnotationsUpdatedAfterDate(date: lastOnlineDatetime) ?? []

        let message = AnnotatoOfflineToOnlineMessage(mergeStrategy: mergeStrategy,
                                                     lastOnlineAt: lastOnlineDatetime,
                                                     documents: documents, annotations: annotations)

        WebSocketManager.shared.send(message: message)
    }
}
