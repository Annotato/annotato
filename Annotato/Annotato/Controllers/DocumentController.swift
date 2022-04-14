import Foundation

struct DocumentController {
    private let webSocketManager: WebSocketManager?
    private let documentsPersistenceManager: DocumentsPersistenceManager

    // MARK: Is this a good idea? Otherwise the only other place that already contains annotationsPersistenceManager
    // is in document view model
    private let annotationsPersistenceManager: AnnotationsPersistenceManager

    init(webSocketManager: WebSocketManager?) {
        self.webSocketManager = webSocketManager
        self.documentsPersistenceManager = DocumentsPersistenceManager(
            webSocketManager: webSocketManager
        )
        self.annotationsPersistenceManager = AnnotationsPersistenceManager(webSocketManager: webSocketManager)
    }

    func loadOwnDocuments(userId: String) async -> [DocumentListCellViewModel] {
        let documents = await documentsPersistenceManager.getOwnDocuments(userId: userId)
        guard let documents = documents else {
            return []
        }

        return documents
            .filter { !$0.isDeleted }
            .map { DocumentListCellViewModel(document: $0, isShared: false) }
    }

    func loadSharedDocuments(userId: String) async -> [DocumentListCellViewModel] {
        let documents = await documentsPersistenceManager.getSharedDocuments(userId: userId)
        guard let documents = documents else {
            return []
        }

        return documents
            .filter { !$0.isDeleted }
            .map { DocumentListCellViewModel(document: $0, isShared: true) }
    }

    func loadAllDocuments(userId: String) async -> [DocumentListCellViewModel] {
        let ownDocuments = await loadOwnDocuments(userId: userId)
        let sharedDocuments = await loadSharedDocuments(userId: userId)
        let allDocuments = ownDocuments + sharedDocuments
        let sortedDocuments = allDocuments.sorted(by: { $0.name < $1.name })
        return sortedDocuments
    }

    func loadDocumentWithDeleted(documentId: UUID) async -> DocumentViewModel? {
        if let resultDocumentWithConflictResolution = await loadLocalAndRemoteDocumentWithDeleted(
            documentId: documentId) {
            return resultDocumentWithConflictResolution
        }
        let document = await documentsPersistenceManager.getDocument(documentId: documentId)
        guard let document = document else {
            return nil
        }

        return DocumentViewModel(
            model: document,
            webSocketManager: webSocketManager,
            annotationsPersistenceManager: annotationsPersistenceManager
        )
    }

    private func loadLocalAndRemoteDocumentWithDeleted(documentId: UUID) async -> DocumentViewModel? {
        let localAndRemoteDocumentPair = await documentsPersistenceManager.getLocalAndRemoteDocument(
            documentId: documentId)
        guard let localDocument = localAndRemoteDocumentPair.local,
              let serverDocument = localAndRemoteDocumentPair.remote else {
            AnnotatoLogger.error("Could not load from local and remote for conflict resolution")
            return nil
        }
        let localAnnotations = localDocument.annotations
        let serverAnnotations = serverDocument.annotations
        let conflictResolution = ConflictResolver(
            localModels: localAnnotations, serverModels: serverAnnotations).resolve()

        await annotationsPersistenceManager.updatePersistenceBasedOnConflictResolution(
            conflictResolution: conflictResolution)
        print("Saved the non conflicted models to persistence already\n\n")
        // Use server document as a base
        for nonConflictingAnnotation in conflictResolution.nonConflictingModels {
            print("non conflicted model:")
            print("\(nonConflictingAnnotation)\n\n")
            if !serverDocument.contains(annotation: nonConflictingAnnotation) {
                serverDocument.addAnnotation(annotation: nonConflictingAnnotation)
            }
        }

        var currentConflictIdx = 1
        for (localAnnotation, serverAnnotation) in conflictResolution.conflictingModels {
            print("Conflicted model with id=\(currentConflictIdx):")
            let newLocalAnnotation = localAnnotation.clone()
            newLocalAnnotation.conflictIdx = currentConflictIdx
            serverAnnotation.conflictIdx = currentConflictIdx
            currentConflictIdx += 1
            serverDocument.addAnnotation(annotation: newLocalAnnotation)

            print("local: \(localAnnotation)\n")
            print("cloned local: \(newLocalAnnotation)\n")
            print("server: \(serverAnnotation)\n\n")

            if !serverDocument.contains(annotation: serverAnnotation) {
                // Probably will never come here but just to be safe, shall I take out?
                serverDocument.addAnnotation(annotation: serverAnnotation)
            }
        }

        return DocumentViewModel(
            model: serverDocument,
            webSocketManager: webSocketManager,
            annotationsPersistenceManager: annotationsPersistenceManager
        )
        // TODO: IMPT Do I need to do some kind of rollback here to ensure core data doesn't have any issues?
    }

    @discardableResult func updateDocumentWithDeleted(document: DocumentViewModel) async -> DocumentViewModel? {
        let updatedDocument = await documentsPersistenceManager.updateDocument(
            document: document.model
        )

        guard let updatedDocument = updatedDocument else {
            return nil
        }

        return DocumentViewModel(
            model: updatedDocument,
            webSocketManager: webSocketManager,
            annotationsPersistenceManager: annotationsPersistenceManager
        )
    }
}
