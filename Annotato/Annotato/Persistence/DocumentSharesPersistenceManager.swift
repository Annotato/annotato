import AnnotatoSharedLibrary
import Foundation

class DocumentSharesPersistenceManager: DocumentSharesPersistence {
    private let remotePersistence = RemotePersistenceService()
    private let localPersistence = LocalPersistenceService.shared

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
                                 context: "PersistenceManager::copyDocumentPDFToLocalStorage")
            return false
        }

        guard let documentPDFData = try? await URLSessionHTTPService().get(url: downloadURL.absoluteString) else {
            AnnotatoLogger.error("Could not retrieve document PDF data using HTTP",
                                 context: "PersistenceManager::copyDocumentPDFToLocalStorage")
            return false
        }

        let wasPDFSavedLocally = LocalStorage().uploadPdf(pdfData: documentPDFData, fileName: document.id.uuidString)
        guard wasPDFSavedLocally else {
            AnnotatoLogger.error("Could not save document PDF to local file system",
                                 context: "PersistenceManager::copyDocumentPDFToLocalStorage")
            return false
        }

        return true
    }
}
