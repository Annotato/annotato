import Foundation
import AnnotatoSharedLibrary

extension OnlinePersistenceService: AnnotatoPdfStorageManager {
    func uploadPdf(fileSystemUrl: URL, withName name: String, completion: @escaping (Document) -> Void) {
        AnnotatoOnlinePdfStorageManager(persistenceService: self)
            .uploadPdf(fileSystemUrl: fileSystemUrl, withName: name, completion: completion)
    }

    func deletePdf(document: Document, completion: @escaping (Document) -> Void) {
        AnnotatoOnlinePdfStorageManager(persistenceService: self)
            .deletePdf(document: document, completion: completion)
    }
}
