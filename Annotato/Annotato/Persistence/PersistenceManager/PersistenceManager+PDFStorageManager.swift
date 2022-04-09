import Foundation
import AnnotatoSharedLibrary

extension PersistenceManager: PDFStorageManager {
    func uploadPdf(fileSystemUrl: URL, withName name: String, completion: @escaping (Document) -> Void) {
        OnlinePDFStorageManager(persistenceManager: self)
            .uploadPdf(fileSystemUrl: fileSystemUrl, withName: name, completion: { _ in })

        OfflinePDFStorageManager(persistenceManager: self)
            .uploadPdf(fileSystemUrl: fileSystemUrl, withName: name, completion: completion)
    }

    func deletePdf(document: Document, completion: @escaping (Document) -> Void) {
        OnlinePDFStorageManager(persistenceManager: self)
            .deletePdf(document: document, completion: { _ in })

        OfflinePDFStorageManager(persistenceManager: self)
            .deletePdf(document: document, completion: completion)
    }
}
