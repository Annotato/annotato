import AnnotatoSharedLibrary

struct LocalDocumentSharesPersistence: DocumentSharesPersistence {
    func createDocumentShare(documentShare: DocumentShare) -> DocumentShare? {
        fatalError("Should not create DocumentShare in local persistence!")
        return nil
    }
}
