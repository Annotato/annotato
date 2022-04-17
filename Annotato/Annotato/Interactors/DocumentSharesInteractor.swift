import AnnotatoSharedLibrary
import Foundation

class DocumentSharesInteractor {
    private let remoteDocumentSharesPersistence = RemoteDocumentSharesPersistence()
    private let localDocumentsPersistence = LocalDocumentsPersistence()

    func createDocumentShare(documentShare: DocumentShare) async -> Document? {
        guard let remoteDocument = await remoteDocumentSharesPersistence
            .createDocumentShare(documentShare: documentShare) else {
            return nil
        }

        await PDFStorageManager().downloadPdfToLocalStorage(fileName: remoteDocument.id.uuidString)

        let localSharedDocument = localDocumentsPersistence.createDocument(document: remoteDocument)
        return localSharedDocument
    }

    func deleteDocumentShare(document: Document, recipientId: String) async -> Document? {
        let remoteDeletedDocument = await remoteDocumentSharesPersistence.deleteDocumentShare(
            documentId: document.id, recipientId: recipientId)

        // Note: Documents are permanently deleted locally
        return localDocumentsPersistence.deleteDocument(document: remoteDeletedDocument ?? document)
    }
}
