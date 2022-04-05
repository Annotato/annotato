import AnnotatoSharedLibrary

protocol PersistenceService: AnnotationsPersistence, DocumentsPersistence, DocumentSharesPersistence {
    func fastForwardLocalDocuments(documents: [Document]) async
    func fastForwardLocalAnnotations(annotations: [Annotation]) async
}
