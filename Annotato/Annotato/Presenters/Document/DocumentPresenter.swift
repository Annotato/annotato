import CoreGraphics
import Foundation
import AnnotatoSharedLibrary
import Combine

class DocumentPresenter: ObservableObject {
    private let documentsPersistenceManager: DocumentsPersistenceManager
    private let annotationsPersistenceManager: AnnotationsPersistenceManager
    private let webSocketManager: WebSocketManager?

    private(set) var model: Document?

    private(set) var annotations: [AnnotationPresenter] = []
    private(set) var pdfDocument: PdfPresenter?
    private var selectionStartPoint: CGPoint?
    private var selectionEndPoint: CGPoint?

    private var cancellables: Set<AnyCancellable> = []

    @Published private(set) var addedAnnotation: AnnotationPresenter?
    @Published private(set) var selectionBoxFrame: CGRect?
    @Published private(set) var updateOwnerIsSuccess: Bool?
    @Published private(set) var hasUpdatedDocument = false
    @Published private(set) var hasDeletedDocument = false

    init(webSocketManager: WebSocketManager?, model: Document? = nil) {
        self.webSocketManager = webSocketManager
        self.documentsPersistenceManager = DocumentsPersistenceManager(webSocketManager: webSocketManager)
        self.annotationsPersistenceManager = AnnotationsPersistenceManager(webSocketManager: webSocketManager)

        self.model = model
        if let model = model {
            self.pdfDocument = PdfPresenter(document: model)
            self.annotations = model.annotations
                .filter { !$0.isDeleted }
                .map { AnnotationPresenter(model: $0, document: self, webSocketManager: webSocketManager) }
        }

        setUpSubscribers()
    }

    func setAllAnnotationsOutOfFocus() {
        for annotation in annotations {
            annotation.outOfFocus()
        }
    }

    func setAllOtherAnnotationsOutOfFocus(except annotationInFocus: AnnotationPresenter) {
        for annotation in annotations where annotation.id != annotationInFocus.id {
            annotation.outOfFocus()
        }
    }
}

extension DocumentPresenter {
    func setSelectionBoxStartPoint(point: CGPoint) {
        selectionStartPoint = point
        updateSelectionBoxFrame()
    }

    func setSelectionBoxEndPoint(point: CGPoint) {
        selectionEndPoint = point
        updateSelectionBoxFrame()
    }

    private func updateSelectionBoxFrame() {
        guard let selectionStartPoint = selectionStartPoint,
              let selectionEndPoint = selectionEndPoint else {
            selectionBoxFrame = nil
            return
        }

        selectionBoxFrame = CGRect(startPoint: selectionStartPoint, endPoint: selectionEndPoint)
    }

    private func resetSelectionPoints() {
        selectionStartPoint = nil
        selectionEndPoint = nil
        selectionBoxFrame = nil
    }

    func addAnnotation(bounds: CGRect) {
        guard let selectionStartPoint = selectionStartPoint,
              let selectionEndPoint = selectionEndPoint,
              let selectionBoxFrame = selectionBoxFrame,
              let currentUser = AuthPresenter().currentUser,
              let model = model else {
            return
        }

        resetSelectionPoints()

        let annotationId = UUID()
        let annotationWidth = 300.0
        let selectionBox = SelectionBox(startPoint: selectionStartPoint,
                                        endPoint: selectionEndPoint,
                                        annotationId: annotationId)

        let newAnnotation = Annotation(
            origin: selectionBoxFrame.center,
            width: annotationWidth,
            parts: [],
            selectionBox: selectionBox,
            ownerId: currentUser.id,
            documentId: model.id,
            id: annotationId
        )

        model.addAnnotation(annotation: newAnnotation)

        let annotationViewModel = AnnotationPresenter(model: newAnnotation, document: self,
                                                      webSocketManager: webSocketManager)
        if annotationViewModel.hasExceededBounds(bounds: bounds) {
            let boundsMidX = bounds.midX
            let annotationY = annotationViewModel.frame.midY
            annotationViewModel.center = CGPoint(x: boundsMidX, y: annotationY)
        }

        annotationViewModel.enterEditMode()
        annotationViewModel.enterMaximizedMode()

        annotations.append(annotationViewModel)
        addedAnnotation = annotationViewModel

        Task {
            await annotationsPersistenceManager.createAnnotation(annotation: newAnnotation)
        }
    }

    func receiveNewAnnotation(newAnnotation: Annotation) {
        guard !newAnnotation.isDeleted else {
            return
        }

        self.model?.addAnnotation(annotation: newAnnotation)
        let annotationViewModel = AnnotationPresenter(model: newAnnotation, document: self,
                                                      webSocketManager: webSocketManager)
        self.annotations.append(annotationViewModel)
        self.addedAnnotation = annotationViewModel
    }

    func receiveUpdateAnnotation(updatedAnnotation: Annotation) {
        if let annotationViewModel = annotations.first(where: { $0.id == updatedAnnotation.id }) {
            if updatedAnnotation.isDeleted {
                receiveDeleteAnnotation(deletedAnnotation: updatedAnnotation)
            } else {
                model?.updateAnnotation(updatedAnnotation: updatedAnnotation)
                annotationViewModel.receiveUpdate(updatedAnnotation: updatedAnnotation)
            }
        } else {
            receiveRestoreDeletedAnnotation(annotation: updatedAnnotation)
        }
    }

    private func receiveRestoreDeletedAnnotation(annotation: Annotation) {
        model?.receiveRestoreDeletedAnnotation(annotation: annotation)
        let annotationViewModel = AnnotationPresenter(model: annotation, document: self,
                                                      webSocketManager: webSocketManager)
        self.annotations.append(annotationViewModel)
        self.addedAnnotation = annotationViewModel
    }

    func deleteAnnotation(annotation: AnnotationPresenter) {
        removeAnnotation(annotation: annotation)
        Task {
            await annotationsPersistenceManager.deleteAnnotation(annotation: annotation.model)
        }
    }

    func removeAnnotation(annotation: AnnotationPresenter) {
        annotations.removeAll(where: { $0.id == annotation.model.id })
    }

    func receiveDeleteAnnotation(deletedAnnotation: Annotation) {
        guard deletedAnnotation.isDeleted else {
            return
        }

        model?.updateAnnotation(updatedAnnotation: deletedAnnotation)
        let annotationViewModel = annotations.first(where: { $0.id == deletedAnnotation.id })
        annotationViewModel?.receiveDelete()
        annotations.removeAll(where: { $0.model.id == deletedAnnotation.id })
    }

    func receiveCreatedOrUpdatedAnnotation(createdOrUpdatedAnnotation: Annotation) {
        if model?.contains(annotation: createdOrUpdatedAnnotation) ?? false {
            AnnotatoLogger.info("Updated annotation from the createOrUpdate path: \(createdOrUpdatedAnnotation)")
            receiveUpdateAnnotation(updatedAnnotation: createdOrUpdatedAnnotation)
        } else {
            AnnotatoLogger.info("New annotation from the createOrUpdate path: \(createdOrUpdatedAnnotation)")
            receiveNewAnnotation(newAnnotation: createdOrUpdatedAnnotation)
        }
    }

    func receiveUpdateDocument(updatedDocument: Document) {
        self.pdfDocument = PdfPresenter(document: updatedDocument)
        self.annotations = updatedDocument.annotations
            .filter { !$0.isDeleted }
            .map { AnnotationPresenter(model: $0, document: self, webSocketManager: webSocketManager) }

        self.model = updatedDocument
        self.hasUpdatedDocument = true
    }

    func receiveDeleteDocument(deletedDocument: Document) {
        guard deletedDocument.isDeleted else {
            return
        }

        hasDeletedDocument = true
    }
}

extension DocumentPresenter {
    func loadDocumentWithDeleted(documentId: UUID) async {
        if let resultDocumentWithConflictResolution = await loadResolvedDocument(documentId: documentId) {
            receiveUpdateDocument(updatedDocument: resultDocumentWithConflictResolution)
            return
        }

        guard let model = await documentsPersistenceManager.getDocument(documentId: documentId) else {
            return
        }

        receiveUpdateDocument(updatedDocument: model)
    }

    private func loadResolvedDocument(documentId: UUID) async -> Document? {
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

        return serverDocument
    }

    func updateDocumentWithDeleted() async {
        guard let model = self.model else {
            return
        }

        guard let updatedModel = await documentsPersistenceManager.updateDocument(document: model) else {
            return
        }

        receiveUpdateDocument(updatedDocument: updatedModel)
    }

    func updateOwner(newOwnerId: String) {
        guard let model = model else {
            return
        }

        model.ownerId = newOwnerId

        Task {
            let deletedDocument = await documentsPersistenceManager.updateDocument(document: model)
            if let deletedDocument = deletedDocument {
                _ = documentsPersistenceManager.deleteDocumentLocally(document: deletedDocument)
                updateOwnerIsSuccess = true
                return
            }

            updateOwnerIsSuccess = false
        }
    }
}

// MARK: Websocket
extension DocumentPresenter {
    private func setUpSubscribers() {
        annotationsPersistenceManager.$newAnnotation.sink { [weak self] newAnnotation in
            guard let newAnnotation = newAnnotation,
                  newAnnotation.documentId == self?.model?.id else {
                return
            }

            self?.receiveNewAnnotation(newAnnotation: newAnnotation)
        }.store(in: &cancellables)

        annotationsPersistenceManager.$updatedAnnotation.sink { [weak self] updatedAnnotation in
            guard let updatedAnnotation = updatedAnnotation,
                  updatedAnnotation.documentId == self?.model?.id else {
                return
            }

            self?.receiveUpdateAnnotation(updatedAnnotation: updatedAnnotation)
        }.store(in: &cancellables)

        annotationsPersistenceManager.$deletedAnnotation.sink { [weak self] deletedAnnotation in
            guard let deletedAnnotation = deletedAnnotation,
                  deletedAnnotation.documentId == self?.model?.id else {
                return
            }

            self?.receiveDeleteAnnotation(deletedAnnotation: deletedAnnotation)
        }.store(in: &cancellables)

        annotationsPersistenceManager.$createdOrUpdatedAnnotation.sink { [weak self] savedAnnotation in
            guard let savedAnnotation = savedAnnotation,
                  savedAnnotation.documentId == self?.model?.id else {
                return
            }
            self?.receiveCreatedOrUpdatedAnnotation(createdOrUpdatedAnnotation: savedAnnotation)
        }.store(in: &cancellables)

        documentsPersistenceManager.$updatedDocument.sink(receiveValue: { [weak self] updatedDocument in
            guard let updatedDocument = updatedDocument,
                  updatedDocument.id == self?.model?.id else {
                return
            }

            self?.receiveUpdateDocument(updatedDocument: updatedDocument)
        }).store(in: &cancellables)

        documentsPersistenceManager.$deletedDocument.sink(receiveValue: { [weak self] deletedDocument in
            guard let deletedDocument = deletedDocument,
                  deletedDocument.id == self?.model?.id else {
                return
            }

            self?.receiveDeleteDocument(deletedDocument: deletedDocument)
        }).store(in: &cancellables)
    }
}
