import CoreGraphics
import Foundation
import AnnotatoSharedLibrary
import Combine

class DocumentViewModel: ObservableObject {
    private let document: Document

    private(set) var annotations: [AnnotationViewModel]
    private(set) var pdfDocument: PdfViewModel

    @Published private(set) var annotationToAdd: AnnotationViewModel?

    init?(document: Document) {
        self.document = document
        self.annotations = document.annotations.map { AnnotationViewModel(annotation: $0) }

        guard let baseFileUrl = URL(string: document.baseFileUrl) else {
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
            documentId: document.id,
            id: UUID()
        )
        document.addAnnotation(annotation: newAnnotation)

        let annotationViewModel = AnnotationViewModel(annotation: newAnnotation)
        annotationViewModel.center = center
        annotationViewModel.enterEditMode()
        annotationViewModel.enterMaximizedMode()

        if annotationViewModel.hasExceededBounds(bounds: bounds) {
            return
        }
        annotations.append(annotationViewModel)
        annotationToAdd = annotationViewModel
    }
}
