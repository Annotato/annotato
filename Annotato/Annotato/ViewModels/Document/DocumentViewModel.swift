import CoreGraphics
import Foundation
import AnnotatoSharedLibrary
import Combine

class DocumentViewModel: ObservableObject {
    let model: Document
    private var cancellables: Set<AnyCancellable> = []

    private(set) var annotations: [AnnotationViewModel] = []
    private(set) var pdfDocument: PdfViewModel

    @Published private(set) var addedAnnotation: AnnotationViewModel?
    @Published private(set) var addedSelectionBox: SelectionBoxViewModel?

    init?(model: Document) {
        guard let baseFileUrl = URL(string: model.baseFileUrl) else {
            return nil
        }
        self.model = model
        self.pdfDocument = PdfViewModel(baseFileUrl: baseFileUrl)
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
    func addAnnotationIfWithinBounds(center: CGPoint, bounds: CGRect) {
        guard let addedSelectionBox = addedSelectionBox else {
            // If we click outside the document, there will not be a selection box
            return
        }
        guard let currentUser = AnnotatoAuth().currentUser else {
            addedSelectionBox.didDelete()
            return
        }
        let newAnnotationWidth = 300.0
        let newAnnotation = Annotation(
            origin: .zero,
            width: newAnnotationWidth,
            parts: [],
            selectionBox: addedSelectionBox.model,
            ownerId: currentUser.uid,
            documentId: model.id,
            id: UUID()
        )
        model.addAnnotation(annotation: newAnnotation)

        let annotationViewModel = AnnotationViewModel(model: newAnnotation, document: self)
        annotationViewModel.center = center
        /*
         Reassign the annotationId of the selection box to be this one because the initial one that I
         initialized at init is a placeholder
         */
        addedSelectionBox.annotationId = annotationViewModel.id

        /*
         Need to reassign the selection box to the added one, because the init for annotation view model will create a
         brand new instance which is not what we want. Yet we cannot change the constructor of the annotation model
         to take in a selection box view model instead, because in the future we will want to load from persisted data
         and persisted data uses models.
         */
        annotationViewModel.selectionBox = addedSelectionBox

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
    }

    func updateCurrentSelectionBoxEndPoint(newEndPoint: CGPoint, bounds: CGRect) {
        guard let addedSelectionBox = addedSelectionBox else {
            return
        }
        if addedSelectionBox.hasExceededBounds(bounds: bounds) {
            return
        }
        addedSelectionBox.updateEndPoint(newEndPoint: newEndPoint)
    }

    func addSelectionBoxIfWithinBounds(startPoint: CGPoint, bounds: CGRect) {
        guard AnnotatoAuth().currentUser != nil else {
            return
        }
        let newSelectionBox = SelectionBox(
            startPoint: startPoint,
            endPoint: startPoint,
            annotationId: UUID(),
            id: UUID()
        )
        let selectionBoxViewModel = SelectionBoxViewModel(model: newSelectionBox)
        if selectionBoxViewModel.hasExceededBounds(bounds: bounds) {
            return
        }
        addedSelectionBox = selectionBoxViewModel
    }

    func addAnnotationWithAssociatedSelectionBoxIfWithinBounds(bounds: CGRect) {
        guard let addedSelectionBox = addedSelectionBox else {
            return
        }
        addAnnotationIfWithinBounds(center: addedSelectionBox.startPoint, bounds: bounds)
        self.addedSelectionBox = nil
    }

    func removeAnnotation(annotation: AnnotationViewModel) {
        model.removeAnnotation(annotation: annotation.model)
        annotations.removeAll(where: { $0.model.id == annotation.model.id })
    }
}
