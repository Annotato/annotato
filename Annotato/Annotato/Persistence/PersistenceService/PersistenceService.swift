protocol PersistenceService {
    var documents: DocumentsPersistence { get }
    var annotations: AnnotationsPersistence { get }
    var documentShares: DocumentSharesPersistence { get }
}
