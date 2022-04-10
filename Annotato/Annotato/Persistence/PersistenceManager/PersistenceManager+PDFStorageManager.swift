import Foundation
import AnnotatoSharedLibrary

extension PersistenceManager {
    func uploadPdf(fileSystemUrl: URL, withName name: String, completion: @escaping (Document) -> Void) {
        PDFStorageManager(persistenceManager: self)
            .uploadPdf(fileSystemUrl: fileSystemUrl, withName: name, completion: completion)
    }

    func deletePdf(document: Document, completion: @escaping (Document) -> Void) {
        PDFStorageManager(persistenceManager: self)
            .deletePdf(document: document, completion: completion)
    }
}
