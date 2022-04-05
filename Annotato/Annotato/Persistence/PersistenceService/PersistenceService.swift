import AnnotatoSharedLibrary

protocol PersistenceService: AnnotationsPersistence, DocumentsPersistence, DocumentSharesPersistence, PDFStorageManager {
    func fastForwardLocalDocuments(documents: [Document])
    func fastForwardLocalAnnotations(annotations: [Annotation])
}
