class DocumentViewModel {
    private(set) var annotations: [DocumentAnnotationViewModel]

    init(annotations: [DocumentAnnotationViewModel]) {
        self.annotations = annotations
    }
}
