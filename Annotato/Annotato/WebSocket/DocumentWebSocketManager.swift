import Foundation
import AnnotatoSharedLibrary

class DocumentWebSocketManager: ObservableObject {
    @Published private(set) var newDocument: Document?
    @Published private(set) var readDocument: Document?
    @Published private(set) var updatedDocument: Document?
    @Published private(set) var deletedDocument: Document?

    func handleResponseData(data: Data) {
        do {
            AnnotatoLogger.info("Handling document response data...")

            let message = try JSONCustomDecoder().decode(AnnotatoCrudDocumentMessage.self, from: data)
            let document = message.document

            // Defensive resets
            newDocument = nil
            readDocument = nil
            updatedDocument = nil
            deletedDocument = nil

            switch message.subtype {
            case .createDocument:
                newDocument = document
                AnnotatoLogger.info("Document was created. \(document)")
            case .readDocument:
                readDocument = document
                AnnotatoLogger.info("Document was read. \(document)")
            case .updateDocument:
                updatedDocument = document
                AnnotatoLogger.info("Document was updated. \(document)")
            case .deleteDocument:
                deletedDocument = document
                AnnotatoLogger.info("Document was deleted. \(document)")
            }

            _ = LocalPersistenceManager.shared.documents.createOrUpdateDocument(document: document)
        } catch {
            AnnotatoLogger.error(
                "When handling response data. \(error.localizedDescription).",
                context: "DocumentWebSocketManager::handleResponseData"
            )
        }
    }
}
