import AnnotatoSharedLibrary

protocol DocumentSharesPersistence {
    func createDocumentShare(documentShare: DocumentShare) async -> DocumentShare?
}
