import CoreGraphics
import Foundation
import AnnotatoSharedLibrary
import Combine

class DocumentViewModel: ObservableObject {
    private let annotationsPersistenceManager: AnnotationsPersistenceManager
    private let webSocketManager: WebSocketManager?

    let model: Document

    private(set) var annotations: [AnnotationViewModel] = []
    private(set) var pdfDocument: PdfViewModel
    private var selectionStartPoint: CGPoint?
    private var selectionEndPoint: CGPoint?

    private var cancellables: Set<AnyCancellable> = []

    @Published private(set) var addedAnnotation: AnnotationViewModel?
    @Published private(set) var selectionBoxFrame: CGRect?

    init(
        model: Document,
        webSocketManager: WebSocketManager?,
        annotationsPersistenceManager: AnnotationsPersistenceManager
    ) {
        self.model = model
        self.pdfDocument = PdfViewModel(document: model)
        self.webSocketManager = webSocketManager
        self.annotationsPersistenceManager = annotationsPersistenceManager

        self.annotations = model.annotations
            .filter { !$0.isDeleted }
            .map { AnnotationViewModel(model: $0, document: self, webSocketManager: webSocketManager) }

        setUpSubscribers()
    }

    func setAllAnnotationsOutOfFocus() {
        for annotation in annotations {
            annotation.outOfFocus()
        }
    }

    func setAllOtherAnnotationsOutOfFocus(except annotationInFocus: AnnotationViewModel) {
        for annotation in annotations where annotation.id != annotationInFocus.id {
            annotation.outOfFocus()
        }
    }
}

extension DocumentViewModel {
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
              let currentUser = AuthViewModel().currentUser else {
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

        let annotationViewModel = AnnotationViewModel(model: newAnnotation, document: self,
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

        self.model.addAnnotation(annotation: newAnnotation)
        let annotationViewModel = AnnotationViewModel(model: newAnnotation, document: self,
                                                      webSocketManager: webSocketManager)
        self.annotations.append(annotationViewModel)
        self.addedAnnotation = annotationViewModel
    }

    func receiveUpdateAnnotation(updatedAnnotation: Annotation) {
        if let annotationViewModel = annotations.first(where: { $0.id == updatedAnnotation.id }) {
            if updatedAnnotation.isDeleted {
                receiveDeleteAnnotation(deletedAnnotation: updatedAnnotation)
            } else {
                annotationViewModel.receiveUpdate(updatedAnnotation: updatedAnnotation)
            }
        } else {
            receiveRestoreDeletedAnnotation(annotation: updatedAnnotation)
        }
    }

    private func receiveRestoreDeletedAnnotation(annotation: Annotation) {
        model.receiveRestoreDeletedAnnotation(annotation: annotation)
        let annotationViewModel = AnnotationViewModel(model: annotation, document: self,
                                                      webSocketManager: webSocketManager)
        self.annotations.append(annotationViewModel)
        self.addedAnnotation = annotationViewModel
    }

    func deleteAnnotation(annotation: AnnotationViewModel) {
        removeAnnotation(annotation: annotation)
        Task {
            await annotationsPersistenceManager.deleteAnnotation(annotation: annotation.model)
        }
    }

    func removeAnnotation(annotation: AnnotationViewModel) {
        model.removeAnnotation(annotation: annotation.model)
        annotations.removeAll(where: { $0.id == annotation.model.id })
    }

    func receiveDeleteAnnotation(deletedAnnotation: Annotation) {
        guard deletedAnnotation.isDeleted else {
            return
        }

        model.removeAnnotation(annotation: deletedAnnotation)
        let annotationViewModel = annotations.first(where: { $0.id == deletedAnnotation.id })
        annotationViewModel?.receiveDelete()
        annotations.removeAll(where: { $0.model.id == deletedAnnotation.id })
    }

    func receiveCreatedOrUpdatedAnnotation(createdOrUpdatedAnnotation: Annotation) {
        if model.contains(annotation: createdOrUpdatedAnnotation) {
            AnnotatoLogger.info("Updated annotation from the createOrUpdate path: \(createdOrUpdatedAnnotation)")
            receiveUpdateAnnotation(updatedAnnotation: createdOrUpdatedAnnotation)
        } else {
            AnnotatoLogger.info("New annotation from the createOrUpdate path: \(createdOrUpdatedAnnotation)")
            receiveNewAnnotation(newAnnotation: createdOrUpdatedAnnotation)
        }
    }
}

// MARK: Websocket
extension DocumentViewModel {
    private func setUpSubscribers() {
        annotationsPersistenceManager.$newAnnotation.sink { [weak self] newAnnotation in
            guard let newAnnotation = newAnnotation,
                  newAnnotation.documentId == self?.model.id else {
                return
            }

            self?.receiveNewAnnotation(newAnnotation: newAnnotation)
        }.store(in: &cancellables)

        annotationsPersistenceManager.$updatedAnnotation.sink { [weak self] updatedAnnotation in
            guard let updatedAnnotation = updatedAnnotation,
                  updatedAnnotation.documentId == self?.model.id else {
                return
            }

            self?.receiveUpdateAnnotation(updatedAnnotation: updatedAnnotation)
        }.store(in: &cancellables)

        annotationsPersistenceManager.$deletedAnnotation.sink { [weak self] deletedAnnotation in
            guard let deletedAnnotation = deletedAnnotation,
                  deletedAnnotation.documentId == self?.model.id else {
                return
            }

            self?.receiveDeleteAnnotation(deletedAnnotation: deletedAnnotation)
        }.store(in: &cancellables)

        annotationsPersistenceManager.$createdOrUpdatedAnnotation.sink { [weak self] savedAnnotation in
            guard let savedAnnotation = savedAnnotation,
                  savedAnnotation.documentId == self?.model.id else {
                return
            }
            self?.receiveCreatedOrUpdatedAnnotation(createdOrUpdatedAnnotation: savedAnnotation)
        }.store(in: &cancellables)
    }
}
