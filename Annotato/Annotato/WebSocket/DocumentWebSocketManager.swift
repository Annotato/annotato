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

            let message = try JSONDecoder().decode(AnnotatoCrudDocumentMessage.self, from: data)
            let document = message.document

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

        } catch {
            AnnotatoLogger.error(
                "When handling reponse data. \(error.localizedDescription).",
                context: "DocumentWebSocketManager:handleResponseData:"
            )
        }
    }
}
