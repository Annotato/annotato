import AnnotatoSharedLibrary
import Foundation

class DocumentSharesPersistenceManager {
    private let remoteDocumentSharesPersistence = RemoteDocumentSharesPersistence()
    private let localDocumentsPersistence = LocalDocumentsPersistence()

    func createDocumentShare(documentShare: DocumentShare) async -> Document? {
        guard let remoteDocument = await remoteDocumentSharesPersistence
            .createDocumentShare(documentShare: documentShare) else {
            return nil
        }

        let wasDocumentCopied = await copyDocumentPDFToLocalStorage(document: remoteDocument)
        guard wasDocumentCopied else {
            return nil
        }

        let localSharedDocument = localDocumentsPersistence.createDocument(document: remoteDocument)
        return localSharedDocument
    }

    func deleteDocumentShare(document: Document, recipientId: String) async -> Document? {
        let remoteDeletedDocument = await remoteDocumentSharesPersistence.deleteDocumentShare(
            documentId: document.id, recipientId: recipientId)

        // Note: Documents are permanently deleted locally
        return localDocumentsPersistence.deleteDocument(document: remoteDeletedDocument ?? document)
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
