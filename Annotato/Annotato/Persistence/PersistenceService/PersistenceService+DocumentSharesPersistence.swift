import AnnotatoSharedLibrary
import Foundation

extension PersistenceService: DocumentSharesPersistence {
    func createDocumentShare(documentShare: DocumentShare) async -> Document? {
        guard let remoteDocument = await remotePersistence
            .documentShares
            .createDocumentShare(documentShare: documentShare) else {
            return nil
        }

        let wasDocumentCopied = await copyDocumentPDFToLocalStorage(document: remoteDocument)
        guard wasDocumentCopied else {
            return nil
        }

        let localSharedDocument = await localPersistence.documents.createDocument(document: remoteDocument)
        return localSharedDocument
    }

    private func copyDocumentPDFToLocalStorage(document: Document) async -> Bool {
        guard let downloadURL = await FirebaseStorage().getDownloadURL(documentId: document.id) else {
            AnnotatoLogger.error("Could not get download URL for document",
                                 context: "PersistenceService::copyDocumentPDFToLocalStorage")
            return false
        }

        guard let documentPDFData = try? await httpService.get(url: downloadURL.absoluteString) else {
            AnnotatoLogger.error("Could not retrieve document PDF data using HTTP",
                                 context: "PersistenceService::copyDocumentPDFToLocalStorage")
            return false
        }

        let wasPDFSavedLocally = LocalStorage().uploadPdf(pdfData: documentPDFData, withId: document.id)
        guard wasPDFSavedLocally else {
            AnnotatoLogger.error("Could not save document PDF to local file system",
                                 context: "PersistenceService::copyDocumentPDFToLocalStorage")
            return false
        }

        return true
    }
}
