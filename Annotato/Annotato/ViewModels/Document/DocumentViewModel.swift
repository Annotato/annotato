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

        let newAnnotationWidth = 300.0
        let newAnnotation = Annotation(
            origin: .zero,
            width: newAnnotationWidth,
            parts: [],
            ownerId: currentUser.uid,
            documentId: model.id,
            id: UUID()
        )
        model.addAnnotation(annotation: newAnnotation)

        let annotationViewModel = AnnotationViewModel(model: newAnnotation)
        annotationViewModel.center = center

        let addedSelectionBox = addedSelectionBox ?? SelectionBoxViewModel(
            id: UUID(),
            startPoint: center,
            endPoint: nil
        )
        annotationViewModel.selectionBox = addedSelectionBox

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
        addedSelectionBox.endPoint = newEndPoint
    }

    func removeAddedSelectionBox() {
        addedSelectionBox = nil
    }

    func addSelectionBoxIfWithinBounds(startPoint: CGPoint, bounds: CGRect) {
        // TODO: Backend models and guard clause for current user

        let selectionBoxViewModel = SelectionBoxViewModel(
            id: UUID(),
            startPoint: startPoint,
            endPoint: nil
        )
        if selectionBoxViewModel.hasExceededBounds(bounds: bounds) {
            return
        }
        addedSelectionBox = selectionBoxViewModel
    }

    func addAnnotationWithAssociatedSelectionBoxIfWithinBounds(bounds: CGRect) {
        guard let addedSelectionBox = addedSelectionBox else {
            print("There is no selection box to associate with")
            return
        }
        addAnnotationIfWithinBounds(center: addedSelectionBox.startPoint, bounds: bounds)

        // Remove the selection box reference
        self.addedSelectionBox = nil
    }
}
