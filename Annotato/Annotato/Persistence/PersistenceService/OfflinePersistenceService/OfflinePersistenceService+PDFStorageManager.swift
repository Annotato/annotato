import Foundation
import AnnotatoSharedLibrary

extension OfflinePersistenceService: PDFStorageManager {
    func uploadPdf(fileSystemUrl: URL, withName name: String, completion: @escaping (Document) -> Void) {
        OfflinePDFStorageManager(persistenceService: self)
            .uploadPdf(fileSystemUrl: fileSystemUrl, withName: name, completion: completion)
    }

    func deletePdf(document: Document, completion: @escaping (Document) -> Void) {
        OfflinePDFStorageManager(persistenceService: self)
            .deletePdf(document: document, completion: completion)
    }
}
