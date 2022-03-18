import CoreGraphics
import Foundation

class DocumentViewModel: ObservableObject {
    private(set) var annotations: [AnnotationViewModel]
    private(set) var pdfDocument: PdfViewModel
    @Published private(set) var annotationToAdd: AnnotationViewModel?

    init(annotations: [AnnotationViewModel], pdfDocument: PdfViewModel) {
        self.annotations = annotations
        self.pdfDocument = pdfDocument
    }
}

extension DocumentViewModel {
    func addAnnotation(
        center: CGPoint,
        pageNumber: String
    ) {
        let newAnnotationWidth = 300.0
        let documentAnnotationViewModel = AnnotationViewModel(
            id: UUID(), origin: .zero,
            pageNumber: pageNumber,
            width: newAnnotationWidth,
            parts: []
        )
        documentAnnotationViewModel.center = center
        documentAnnotationViewModel.enterEditMode()
        annotations.append(documentAnnotationViewModel)
        annotationToAdd = documentAnnotationViewModel
    }
}
