import AnnotatoSharedLibrary

struct LocalDocumentSharesPersistence: DocumentSharesRemotePersistence {
    func createDocumentShare(documentShare: DocumentShare) -> Document? {
        fatalError("Should not create DocumentShare in local persistence!")
        return nil
    }
}
