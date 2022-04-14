import AnnotatoSharedLibrary
import Foundation
import Combine

class AnnotationsPersistenceManager {
    private let webSocketManager: WebSocketManager?
    private let rootPersistenceManager: RootPersistenceManager

    private let remoteAnnotationsPersistence: RemoteAnnotationsPersistence
    private let localAnnotationsPersistence = LocalAnnotationsPersistence()
    private var cancellables: Set<AnyCancellable> = []

    @Published private(set) var newAnnotation: Annotation?
    @Published private(set) var updatedAnnotation: Annotation?
    @Published private(set) var deletedAnnotation: Annotation?
    @Published private(set) var createdOrUpdatedAnnotation: Annotation?

    init(webSocketManager: WebSocketManager?) {
        self.webSocketManager = webSocketManager
        self.rootPersistenceManager = RootPersistenceManager(webSocketManager: webSocketManager)
        self.remoteAnnotationsPersistence = RemoteAnnotationsPersistence(
            webSocketManager: webSocketManager
        )

        setUpSubscribers()
    }

    func createAnnotation(annotation: Annotation) async -> Annotation? {
        _ = await remoteAnnotationsPersistence.createAnnotation(annotation: annotation)

        annotation.setCreatedAt()
        return localAnnotationsPersistence.createAnnotation(annotation: annotation)
    }

    func updateAnnotation(annotation: Annotation) async -> Annotation? {
        _ = await remoteAnnotationsPersistence.updateAnnotation(annotation: annotation)

        annotation.setUpdatedAt()
        return localAnnotationsPersistence.updateAnnotation(annotation: annotation)
    }

    func deleteAnnotation(annotation: Annotation) async -> Annotation? {
        _ = await remoteAnnotationsPersistence.deleteAnnotation(annotation: annotation)

        annotation.setDeletedAt()
        return localAnnotationsPersistence.deleteAnnotation(annotation: annotation)
    }

    func createOrUpdateAnnotation(annotation: Annotation) async -> Annotation? {
        _ = await remoteAnnotationsPersistence.createOrUpdateAnnotation(annotation: annotation)

        if annotation.createdAt == nil {
            annotation.setCreatedAt()
        }
        annotation.setUpdatedAt()
        return localAnnotationsPersistence.createOrUpdateAnnotation(annotation: annotation)
    }
}

// MARK: Websocket
extension AnnotationsPersistenceManager {
    private func setUpSubscribers() {
        rootPersistenceManager.$crudAnnotationMessage.sink { [weak self] message in
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

        let annotation = decodedMessage.annotation
        let senderId = decodedMessage.senderId
        let messageSubtype = decodedMessage.subtype

        _ = localAnnotationsPersistence.createOrUpdateAnnotation(annotation: annotation)

        guard senderId != AuthViewModel().currentUser?.id else {
            return
        }

        publishAnnotation(messageSubtype: messageSubtype, annotation: annotation)
    }

    private func decodeData(data: Data) -> AnnotatoCudAnnotationMessage? {
        do {
            let decodedMessage = try JSONCustomDecoder().decode(AnnotatoCudAnnotationMessage.self, from: data)
            return decodedMessage
        } catch {
            AnnotatoLogger.error(
                "When decoding data. \(error.localizedDescription).",
                context: "AnnotationsPersistenceManager::decodeData"
            )
            return nil
        }
    }

    private func publishAnnotation(messageSubtype: AnnotatoCudAnnotationMessageType, annotation: Annotation) {
        resetPublishedAttributes()

        switch messageSubtype {
        case .createAnnotation:
            newAnnotation = annotation
            AnnotatoLogger.info("Annotation was created. \(annotation)")
        case .updateAnnotation:
            updatedAnnotation = annotation
            AnnotatoLogger.info("Annotation was updated. \(annotation)")
        case .deleteAnnotation:
            deletedAnnotation = annotation
            AnnotatoLogger.info("Annotation was deleted. \(annotation)")
        case .createOrUpdateAnnotation:
            createdOrUpdatedAnnotation = annotation
            AnnotatoLogger.info("Annotation was created or updated. \(annotation)")
        }

        resetPublishedAttributes()
    }

    private func resetPublishedAttributes() {
        newAnnotation = nil
        updatedAnnotation = nil
        deletedAnnotation = nil
        createdOrUpdatedAnnotation = nil
    }
}

// MARK: Conflict Resolution Persistence
extension AnnotationsPersistenceManager {
    func updatePersistenceBasedOnConflictResolution(conflictResolution: ConflictResolution<Annotation>) async {
        for localCreateAnnotation in conflictResolution.localCreate {
            _ = localAnnotationsPersistence.createAnnotation(annotation: localCreateAnnotation)
        }

        for localUpdateAnnotation in conflictResolution.localUpdate {
            _ = localAnnotationsPersistence.updateAnnotation(annotation: localUpdateAnnotation)
        }

        for localDeleteAnnotation in conflictResolution.localDelete {
            _ = localAnnotationsPersistence.deleteAnnotation(annotation: localDeleteAnnotation)
        }

        for serverCreateAnnotation in conflictResolution.serverCreate {
            _ = await remoteAnnotationsPersistence.createAnnotation(annotation: serverCreateAnnotation)
        }

        for serverUpdateAnnotation in conflictResolution.serverUpdate {
            _ = await remoteAnnotationsPersistence.updateAnnotation(annotation: serverUpdateAnnotation)
        }

        for serverDeleteAnnotation in conflictResolution.serverDelete {
            _ = await remoteAnnotationsPersistence.deleteAnnotation(annotation: serverDeleteAnnotation)
        }
    }
}
