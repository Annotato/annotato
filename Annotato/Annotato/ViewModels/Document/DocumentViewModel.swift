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
    func addAnnotation(center: CGPoint, pageLabel: String) {
        let newAnnotationWidth = 300.0
        let annotationViewModel = AnnotationViewModel(
            id: UUID(),
            origin: .zero,
            pageLabel: pageLabel,
            width: newAnnotationWidth,
            parts: []
        )
        annotationViewModel.center = center
        annotationViewModel.enterEditMode()
        annotations.append(annotationViewModel)
        annotationToAdd = annotationViewModel
    }
}
