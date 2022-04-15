<<<<<<< HEAD
import Foundation

struct DocumentController {
    private let webSocketManager: WebSocketManager?
    private let documentsPersistenceManager: DocumentsPersistenceManager
    private let annotationsPersistenceManager: AnnotationsPersistenceManager

    init(webSocketManager: WebSocketManager?) {
        self.webSocketManager = webSocketManager
        self.documentsPersistenceManager = DocumentsPersistenceManager(webSocketManager: webSocketManager)
        self.annotationsPersistenceManager = AnnotationsPersistenceManager(webSocketManager: webSocketManager)
    }

    func loadDocumentWithDeleted(documentId: UUID) async -> DocumentViewModel? {
        if let resultDocumentWithConflictResolution = await loadResolvedDocument(documentId: documentId) {
            return resultDocumentWithConflictResolution
        }

        let document = await documentsPersistenceManager.getDocument(documentId: documentId)
        guard let document = document else {
            return nil
        }

        return DocumentViewModel(model: document, webSocketManager: webSocketManager)
    }

    private func loadResolvedDocument(documentId: UUID) async -> DocumentViewModel? {
        let localAndRemoteDocumentPair = await documentsPersistenceManager
            .getLocalAndRemoteDocument(documentId: documentId)
        guard let localDocument = localAndRemoteDocumentPair.local,
              let serverDocument = localAndRemoteDocumentPair.remote else {
            AnnotatoLogger.error("Could not load from local and remote for conflict resolution")
            return nil
        }

        let resolvedAnnotations = ConflictResolver(localModels: localDocument.annotations,
                                                   serverModels: serverDocument.annotations).resolve()

        await annotationsPersistenceManager.persistConflictResolution(conflictResolution: resolvedAnnotations)

        serverDocument.setAnnotations(annotations: resolvedAnnotations.nonConflictingModels)

        for (conflictIdx, (localAnnotation, serverAnnotation)) in resolvedAnnotations.conflictingModels.enumerated() {
            let newLocalAnnotation = localAnnotation.clone()
            newLocalAnnotation.conflictIdx = conflictIdx
            serverAnnotation.conflictIdx = conflictIdx
            serverDocument.addAnnotation(annotation: newLocalAnnotation)
            serverDocument.addAnnotation(annotation: serverAnnotation)
        }

        return DocumentViewModel(model: serverDocument, webSocketManager: webSocketManager)
    }

    @discardableResult func updateDocumentWithDeleted(document: DocumentViewModel) async -> DocumentViewModel? {
        let updatedDocument = await documentsPersistenceManager.updateDocument(document: document.model)

        guard let updatedDocument = updatedDocument else {
            return nil
        }

        return DocumentViewModel(model: updatedDocument, webSocketManager: webSocketManager)
    }
}
=======
// import Foundation
//
// struct DocumentController {
//    private let webSocketManager: WebSocketManager?
//    private let documentsPersistenceManager: DocumentsPersistenceManager
//    private let annotationsPersistenceManager: AnnotationsPersistenceManager
//
//    init(webSocketManager: WebSocketManager?) {
//        self.webSocketManager = webSocketManager
//        self.documentsPersistenceManager = DocumentsPersistenceManager(webSocketManager: webSocketManager)
//        self.annotationsPersistenceManager = AnnotationsPersistenceManager(webSocketManager: webSocketManager)
//    }
//
//    func loadDocumentWithDeleted(documentId: UUID) async -> DocumentViewModel? {
//        if let resultDocumentWithConflictResolution = await loadResolvedDocument(documentId: documentId) {
//            return resultDocumentWithConflictResolution
//        }
//
//        let document = await documentsPersistenceManager.getDocument(documentId: documentId)
//        guard let document = document else {
//            return nil
//        }
//
//        return DocumentViewModel(model: document, webSocketManager: webSocketManager)
//    }
//
//    private func loadResolvedDocument(documentId: UUID) async -> DocumentViewModel? {
//        let localAndRemoteDocumentPair = await documentsPersistenceManager
//            .getLocalAndRemoteDocument(documentId: documentId)
//        guard let localDocument = localAndRemoteDocumentPair.local,
//              let serverDocument = localAndRemoteDocumentPair.remote else {
//            AnnotatoLogger.error("Could not load from local and remote for conflict resolution")
//            return nil
//        }
//
//        let resolvedAnnotations = ConflictResolver(localModels: localDocument.annotations,
//                                                   serverModels: serverDocument.annotations).resolve()
//
//        await annotationsPersistenceManager.persistConflictResolution(conflictResolution: resolvedAnnotations)
//
//        serverDocument.setAnnotations(annotations: resolvedAnnotations.nonConflictingModels)
//
//        for (conflictIdx, (localAnnotation, serverAnnotation)) in resolvedAnnotations.conflictingModels.enumerated() {
//            let newLocalAnnotation = localAnnotation.clone()
//            newLocalAnnotation.conflictIdx = conflictIdx
//            serverAnnotation.conflictIdx = conflictIdx
//            serverDocument.addAnnotation(annotation: newLocalAnnotation)
//        }
//
//        return DocumentViewModel(model: serverDocument, webSocketManager: webSocketManager)
//    }
//
//    @discardableResult func updateDocumentWithDeleted(document: DocumentViewModel) async -> DocumentViewModel? {
//        let updatedDocument = await documentsPersistenceManager.updateDocument(document: document.model)
//
//        guard let updatedDocument = updatedDocument else {
//            return nil
//        }
//
//        return DocumentViewModel(model: updatedDocument, webSocketManager: webSocketManager)
//    }
// }
>>>>>>> d2cdcae... Remove document controller
