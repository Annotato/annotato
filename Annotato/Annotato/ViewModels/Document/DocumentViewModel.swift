import CoreGraphics
import Foundation
import AnnotatoSharedLibrary
import Combine

class DocumentViewModel: ObservableObject {
    let model: Document
    private var cancellables: Set<AnyCancellable> = []

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
        setUpSubscribers()
    }

    private func setUpSubscribers() {
        for annotation in annotations {
            annotation.$isInFocus.sink(receiveValue: { [weak self] isInFocus in
                if isInFocus {
                    self?.setAllOtherAnnotationsOutOfFocus(except: annotation)
                }
            }).store(in: &cancellables)
        }

        WebSocketManager.shared.annotationManager.$newAnnotation.sink { [weak self] newAnnotation in
            guard let newAnnotation = newAnnotation else {
                return
            }

            guard let self = self else {
                return
            }

            self.model.addAnnotation(annotation: newAnnotation)
            let annotationViewModel = AnnotationViewModel(model: newAnnotation, document: self)
            self.addedAnnotation = annotationViewModel
        }.store(in: &cancellables)
    }

    private func setUpSubscriberForAnnotation(annotation: AnnotationViewModel) {
        annotation.$isInFocus.sink(receiveValue: { [weak self] isInFocus in
            if isInFocus {
                self?.setAllOtherAnnotationsOutOfFocus(except: annotation)
            }
        }).store(in: &cancellables)
    }

    func setAllAnnotationsOutOfFocus() {
        for annotation in annotations {
            annotation.outOfFocus()
        }
    }

    private func setAllOtherAnnotationsOutOfFocus(except annotationInFocus: AnnotationViewModel) {
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
        setUpSubscriberForAnnotation(annotation: annotationViewModel)

        Task {
            await AnnotatoPersistenceWrapper.currentPersistenceService.createAnnotation(annotation: newAnnotation)
        }
    }

    func removeAnnotation(annotation: AnnotationViewModel) {
        model.removeAnnotation(annotation: annotation.model)
        annotations.removeAll(where: { $0.model.id == annotation.model.id })

        Task {
            await AnnotatoPersistenceWrapper.currentPersistenceService.deleteAnnotation(annotation: annotation.model)
        }
    }
}
