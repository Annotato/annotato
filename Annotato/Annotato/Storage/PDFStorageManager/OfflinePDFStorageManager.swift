import Foundation
import AnnotatoSharedLibrary

class OfflinePDFStorageManager: PDFStorageManager {
    private var localStorageService: AnnotatoStorageService
    private let persistenceManager: PersistenceManager

    init(persistenceManager: PersistenceManager) {
        localStorageService = LocalStorage()
        self.persistenceManager = persistenceManager
    }

    var delegate: AnnotatoStorageDelegate? {
        didSet {
            localStorageService.delegate = delegate
        }
    }

    func uploadPdf(fileSystemUrl: URL, withName name: String, completion: @escaping (Document) -> Void) {
        guard let userId = AnnotatoAuth().currentUser?.uid else {
            AnnotatoLogger.error("When getting current user's ID",
                                 context: "OfflinePDFStorageManager::uploadPdf")
            return
        }

        let document = Document(name: name, ownerId: userId, baseFileUrl: nil)

        localStorageService.uploadPdf(fileSystemUrl: fileSystemUrl, withId: document.id)

        Task {
            guard let document = await self.persistenceManager.createDocument(document: document) else {
                return
            }

            AnnotatoLogger.info("Created backend document entry: \(document)")
            completion(document)
        }
    }

    func deletePdf(document: Document, completion: @escaping (Document) -> Void) {
        localStorageService.deletePdf(document: document)

        Task {
            guard let document = await self.persistenceManager.deleteDocument(document: document) else {
                return
            }

            AnnotatoLogger.info("Deleted backend document entry: \(document)")
            completion(document)
        }
    }
}
