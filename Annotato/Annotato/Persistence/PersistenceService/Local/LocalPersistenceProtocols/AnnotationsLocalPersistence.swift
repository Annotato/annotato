import AnnotatoSharedLibrary

protocol AnnotationsLocalPersistence {
    func createAnnotation(annotation: Annotation) -> Annotation?
    func updateAnnotation(annotation: Annotation) -> Annotation?
    func deleteAnnotation(annotation: Annotation) -> Annotation?
    func createOrUpdateAnnotation(annotation: Annotation) -> Annotation?
    func createOrUpdateAnnotations(annotations: [Annotation]) -> [Annotation]?
}
