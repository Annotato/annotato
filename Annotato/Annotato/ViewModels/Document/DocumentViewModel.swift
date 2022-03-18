import CoreGraphics
import Foundation

class DocumentViewModel: ObservableObject {
    private(set) var annotations: [AnnotationViewModel]
    @Published private(set) var annotationToAdd: AnnotationViewModel?
    private(set) var pdfDocument: DocumentPdfViewModel

    init(annotations: [AnnotationViewModel], pdfDocument: DocumentPdfViewModel) {
        self.annotations = annotations
        self.pdfDocument = pdfDocument
    }
}

extension DocumentViewModel {
    func addAnnotation(at point: CGPoint) {
        let newAnnotation = AnnotationViewModel(
            id: UUID(), origin: .zero, width: 300.0, parts: [])
        newAnnotation.center = point
        newAnnotation.enterEditMode()
        annotations.append(newAnnotation)
        annotationToAdd = newAnnotation
    }
}
