import CoreGraphics
import Foundation
import AnnotatoSharedLibrary
import Combine

class DocumentViewModel: ObservableObject {
    private let model: Document

    private(set) var annotations: [AnnotationViewModel]
    private(set) var pdfDocument: PdfViewModel

    @Published private(set) var addedAnnotation: AnnotationViewModel?
    @Published private(set) var addedSelectionBox: SelectionBoxViewModel?

    init?(model: Document) {
        self.model = model
        self.annotations = model.annotations.map { AnnotationViewModel(model: $0) }

        guard let baseFileUrl = URL(string: model.baseFileUrl) else {
            return nil
        }
        self.pdfDocument = PdfViewModel(baseFileUrl: baseFileUrl)
    }
}

extension DocumentViewModel {
    func addAnnotationIfWithinBounds(center: CGPoint, bounds: CGRect) {
        guard let currentUser = AnnotatoAuth().currentUser else {
            return
        }
        guard let addedSelectionBox = addedSelectionBox else {
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
        let annotationViewModel = AnnotationViewModel(model: newAnnotation)
        annotationViewModel.center = center
        /*
         Need to reassign the selection box to the added one, because the init for annotation view model will create a
         brand new instance which is not what we want. Yet we cannot change the constructor of the annotation model
         to take in a selection box view model instead, because in the future we will want to load from persisted data
         and persisted data uses models.
         */
        annotationViewModel.selectionBox = addedSelectionBox

        // Now we create the link line then assign it to the annotation
        let linkLineViewModel = LinkLineViewModel(id: UUID())
        linkLineViewModel.selectionBoxViewModel = annotationViewModel.selectionBox
        linkLineViewModel.annotationViewModel = annotationViewModel
        annotationViewModel.linkLine = linkLineViewModel

        if annotationViewModel.hasExceededBounds(bounds: bounds) {
            model.removeAnnotation(annotation: newAnnotation)
            return
        }

        annotationViewModel.enterEditMode()
        annotationViewModel.enterMaximizedMode()
        annotations.append(annotationViewModel)
        addedAnnotation = annotationViewModel
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
        let newSelectionBox = SelectionBox(id: UUID(), startPoint: startPoint, endPoint: startPoint)
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
}
