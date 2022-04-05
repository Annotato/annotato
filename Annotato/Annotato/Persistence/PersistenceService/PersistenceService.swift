import AnnotatoSharedLibrary

protocol PersistenceService: AnnotationsPersistence, DocumentsPersistence, DocumentSharesPersistence,
                                PDFStorageManager { }
