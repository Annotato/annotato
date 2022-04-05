import CoreGraphics
import Foundation
import AnnotatoSharedLibrary
import Combine

class DocumentViewModel: ObservableObject {
    let model: Document

    private(set) var annotations: [AnnotationViewModel] = []
    private(set) var pdfDocument: PdfViewModel
    private var selectionStartPoint: CGPoint?
    private var selectionEndPoint: CGPoint?

    @Published private(set) var addedAnnotation: AnnotationViewModel?
    @Published private(set) var selectionBoxFrame: CGRect?

    init(model: Document) {
        self.model = model
        self.pdfDocument = PdfViewModel(document: model)
        self.annotations = model.annotations.map { AnnotationViewModel(model: $0, document: self) }
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
              let currentUser = AnnotatoAuth().currentUser else {
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
            ownerId: currentUser.uid,
            documentId: model.id,
            id: annotationId
        )

        model.addAnnotation(annotation: newAnnotation)

        let annotationViewModel = AnnotationViewModel(model: newAnnotation, document: self)
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
            await AnnotatoPersistenceWrapper.currentPersistenceService.createAnnotation(annotation: newAnnotation)
        }
    }

    func receiveNewAnnotation(newAnnotation: Annotation) {
        self.model.addAnnotation(annotation: newAnnotation)
        let annotationViewModel = AnnotationViewModel(model: newAnnotation, document: self)
        self.annotations.append(annotationViewModel)
        self.addedAnnotation = annotationViewModel
    }

    func receiveUpdateAnnotation(updatedAnnotation: Annotation) {
        if let annotationViewModel = annotations.first(where: { $0.id == updatedAnnotation.id }) {
            annotationViewModel.receiveUpdate(updatedAnnotation: updatedAnnotation)
        } else {
            let annotationViewModel = AnnotationViewModel(model: updatedAnnotation, document: self)
            self.annotations.append(annotationViewModel)
            self.addedAnnotation = annotationViewModel
        }
    }

    func removeAnnotation(annotation: AnnotationViewModel) {
        model.removeAnnotation(annotation: annotation.model)
        annotations.removeAll(where: { $0.id == annotation.model.id })

        Task {
            await AnnotatoPersistenceWrapper.currentPersistenceService.deleteAnnotation(annotation: annotation.model)
        }
    }

    func receiveDeleteAnnotation(deletedAnnotation: Annotation) {
        model.removeAnnotation(annotation: deletedAnnotation)
        let annotationViewModel = annotations.first(where: { $0.id == deletedAnnotation.id })
        annotationViewModel?.receiveDelete()
        annotations.removeAll(where: { $0.model.id == deletedAnnotation.id })
    }
}
