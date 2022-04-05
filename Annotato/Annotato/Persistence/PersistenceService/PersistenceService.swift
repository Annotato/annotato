import AnnotatoSharedLibrary

protocol PersistenceService: AnnotationsPersistence, DocumentsPersistence, DocumentSharesPersistence {
    func fastForwardLocalDocuments(documents: [Document])
    func fastForwardLocalAnnotations(annotations: [Annotation])
}
