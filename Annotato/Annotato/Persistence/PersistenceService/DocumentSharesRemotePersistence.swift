import AnnotatoSharedLibrary

protocol DocumentSharesRemotePersistence {
    func createDocumentShare(documentShare: DocumentShare) async -> Document?
}
