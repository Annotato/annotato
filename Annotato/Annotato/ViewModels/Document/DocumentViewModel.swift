import CoreGraphics
import Foundation
import AnnotatoSharedLibrary
import Combine

class DocumentViewModel: ObservableObject {
    private let model: Document

    private(set) var annotations: [AnnotationViewModel]
    private(set) var pdfDocument: PdfViewModel

    /*
     I added this because I think eventually we will need it. But I make it default empty array first because otherwise we can't compile yet
     */
    private(set) var selectionBoxes: [SelectionBoxViewModel] = []

    @Published private(set) var addedAnnotation: AnnotationViewModel?

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

        if annotationViewModel.hasExceededBounds(bounds: bounds) {
            model.removeAnnotation(annotation: newAnnotation)
            return
        }

        annotationViewModel.enterEditMode()
        annotationViewModel.enterMaximizedMode()
        annotations.append(annotationViewModel)
        addedAnnotation = annotationViewModel
    }

    func addSelectionBoxIfWithinBounds(startPoint: CGPoint, bounds: CGRect) {

    }
}
