class DocumentViewModel {
    private(set) var annotations: [AnnotationViewModel]

    init(annotations: [AnnotationViewModel]) {
        self.annotations = annotations
    }
}
