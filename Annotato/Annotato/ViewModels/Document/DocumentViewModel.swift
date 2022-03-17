class DocumentViewModel {
    var annotations: [DocumentAnnotationViewModel]
    private(set) var pdfDocument: DocumentPdfViewModel

    init(annotations: [DocumentAnnotationViewModel], pdfDocument: DocumentPdfViewModel) {
        self.annotations = annotations
        self.pdfDocument = pdfDocument
    }
}
