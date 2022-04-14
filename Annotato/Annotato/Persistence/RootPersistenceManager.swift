import Foundation
import Combine
import AnnotatoSharedLibrary

class RootPersistenceManager: ObservableObject {
    private let webSocketManager: WebSocketManager?
    private var cancellables: Set<AnyCancellable> = []

    @Published private(set) var crudDocumentMessage: Data?
    @Published private(set) var crudAnnotationMessage: Data?

    init(webSocketManager: WebSocketManager?) {
        self.webSocketManager = webSocketManager

        setUpSubscribers()
    }

    private func setUpSubscribers() {
        webSocketManager?.$message.sink { [weak self] message in
            guard let message = message else {
                return
            }

            self?.handleIncomingMessage(message: message)
        }.store(in: &cancellables)
    }

    private func handleIncomingMessage(message: Data) {
        guard let decodedMessage = decodeData(data: message) else {
            return
        }

        let messageType = decodedMessage.type

        publishMessage(decodedMessageType: messageType, message: message)
    }

    private func decodeData(data: Data) -> AnnotatoMessage? {
        do {
            let decodedMessage = try JSONCustomDecoder().decode(AnnotatoMessage.self, from: data)
            return decodedMessage
        } catch {
            AnnotatoLogger.error(
                "When decoding data. \(error.localizedDescription).",
                context: "RootPersistenceManager::decodeData"
            )
            return nil
        }
    }

    private func publishMessage(decodedMessageType: AnnotatoMessageType, message: Data) {
        resetPublishedAttributes()

        switch decodedMessageType {
        case .crudDocument:
            self.crudDocumentMessage = message
        case .crudAnnotation:
            self.crudAnnotationMessage = message
        }

        resetPublishedAttributes()
    }

    private func resetPublishedAttributes() {
        crudDocumentMessage = nil
        crudAnnotationMessage = nil
    }
}
