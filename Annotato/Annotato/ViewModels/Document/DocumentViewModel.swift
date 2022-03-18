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
    func addAnnotation(viewModel: AnnotationViewModel) {
        viewModel.enterEditMode()
        annotations.append(viewModel)
        annotationToAdd = viewModel
    }
}
