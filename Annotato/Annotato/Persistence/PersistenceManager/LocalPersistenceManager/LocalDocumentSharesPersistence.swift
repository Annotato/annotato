import AnnotatoSharedLibrary

struct LocalDocumentSharesPersistence: DocumentSharesPersistence {
    func createDocumentShare(documentShare: DocumentShare) -> Document? {
        fatalError("Should not create DocumentShare in local persistence!")
        return nil
    }
}
