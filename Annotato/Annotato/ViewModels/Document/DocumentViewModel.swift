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
    func addAnnotation(viewModel: AnnotationViewModel) {
        viewModel.enterEditMode()
        annotations.append(viewModel)
        annotationToAdd = viewModel
    }
}
