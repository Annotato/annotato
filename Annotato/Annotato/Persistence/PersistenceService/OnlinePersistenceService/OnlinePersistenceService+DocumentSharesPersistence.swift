import AnnotatoSharedLibrary
import Foundation

extension OnlinePersistenceService: DocumentSharesPersistence {
    func createDocumentShare(documentShare: DocumentShare) async -> Document? {
        guard let sharedDocumentRemote = await remotePersistence
            .documentShares
            .createDocumentShare(documentShare: documentShare) else {
            return nil
        }

        let wasDocumentCopied = await copyDocumentPDFToLocalStorage(document: sharedDocumentRemote)
        guard wasDocumentCopied else {
            return nil
        }

        let sharedDocumentLocal = await localPersistence.documents.createDocument(document: sharedDocumentRemote)
        return sharedDocumentLocal
    }

    private func copyDocumentPDFToLocalStorage(document: Document) async -> Bool {
        guard let downloadURL = await FirebaseStorage().getDownloadURL(documentId: document.id) else {
            AnnotatoLogger.error("Could not get download URL for document",
                                 context: "OnlinePersistenceService::copyDocumentPDFToLocalStorage")
            return false
        }

        guard let documentPDFData = try? await httpService.get(url: downloadURL.absoluteString) else {
            AnnotatoLogger.error("Could not retrieve document PDF data using HTTP",
                                 context: "OnlinePersistenceService::copyDocumentPDFToLocalStorage")
            return false
        }

        let wasPDFSavedLocally = LocalStorage().uploadPdf(pdfData: documentPDFData, withId: document.id)
        guard wasPDFSavedLocally else {
            AnnotatoLogger.error("Could not save document PDF to local file system",
                                 context: "OnlinePersistenceService::copyDocumentPDFToLocalStorage")
            return false
        }

        return true
    }
}
