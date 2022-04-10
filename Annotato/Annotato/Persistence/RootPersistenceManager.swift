import Foundation
import Combine
import AnnotatoSharedLibrary

class RootPersistenceManager: ObservableObject {
    private var cancellables: Set<AnyCancellable> = []

    @Published private(set) var crudDocumentMessage: Data?
    @Published private(set) var crudAnnotationMessage: Data?

    init() {
        setUpSubscribers()
    }

    private func setUpSubscribers() {
        WebSocketManager.shared.$message.sink { [weak self] message in
            guard let message = message else {
                return
            }

            self?.handleIncomingMessage(message: message)
        }.store(in: &cancellables)
    }

    private func handleIncomingMessage(message: Data) {
        do {
            let decodedMessage = try JSONCustomDecoder().decode(AnnotatoMessage.self, from: message)

            // Defensive resets
            crudDocumentMessage = nil
            crudAnnotationMessage = nil

            switch decodedMessage.type {
            case .crudDocument:
                self.crudDocumentMessage = message
            case .crudAnnotation:
                self.crudAnnotationMessage = message
            }
        } catch {
            AnnotatoLogger.error(
                "When handling incoming data. \(error.localizedDescription).",
                context: "RootPersistenceManager::handleIncomingMessage"
            )
        }
    }
}
