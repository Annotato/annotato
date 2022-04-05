import AnnotatoSharedLibrary

protocol AnnotationsPersistence {
    func createAnnotation(annotation: Annotation) async -> Annotation?
    func updateAnnotation(annotation: Annotation) async -> Annotation?
    func deleteAnnotation(annotation: Annotation) async -> Annotation?
    func createOrUpdateAnnotations(annotations: [Annotation]) -> [Annotation]?
}
