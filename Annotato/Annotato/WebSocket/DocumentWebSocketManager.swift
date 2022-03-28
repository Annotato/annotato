import Foundation
import AnnotatoSharedLibrary

class DocumentWebSocketManager: ObservableObject {
    @Published private(set) var newDocument: Document?
    @Published private(set) var readDocument: Document?
    @Published private(set) var updatedDocument: Document?
    @Published private(set) var deletedDocument: Document?

    func handleResponseData(data: Data) {
        do {
            let message = try JSONDecoder().decode(AnnotatoCrudDocumentMessage.self, from: data)
            let document = message.document

            switch message.subtype {
            case .createDocument:
                newDocument = document
            case .readDocument:
                readDocument = document
            case .updateDocument:
                updatedDocument = document
            case .deleteDocument:
                deletedDocument = document
            }

        } catch {
            AnnotatoLogger.error(
                "When handling reponse data. \(error.localizedDescription).",
                context: "DocumentWebSocketManager:handleResponseData:"
            )
        }
    }
}
