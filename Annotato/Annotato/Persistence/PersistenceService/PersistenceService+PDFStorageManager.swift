import Foundation
import AnnotatoSharedLibrary

extension PersistenceService: PDFStorageManager {
    func uploadPdf(fileSystemUrl: URL, withName name: String, completion: @escaping (Document) -> Void) {
        OnlinePDFStorageManager(persistenceService: self)
            .uploadPdf(fileSystemUrl: fileSystemUrl, withName: name, completion: { _ in })

        OfflinePDFStorageManager(persistenceService: self)
            .uploadPdf(fileSystemUrl: fileSystemUrl, withName: name, completion: completion)
    }

    func deletePdf(document: Document, completion: @escaping (Document) -> Void) {
        OnlinePDFStorageManager(persistenceService: self)
            .deletePdf(document: document, completion: { _ in })

        OfflinePDFStorageManager(persistenceService: self)
            .deletePdf(document: document, completion: completion)
    }
}
