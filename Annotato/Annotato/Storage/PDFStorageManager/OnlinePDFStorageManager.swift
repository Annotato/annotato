import Foundation
import AnnotatoSharedLibrary

class OnlinePDFStorageManager: PDFStorageManager {
    private var localStorageService: AnnotatoStorageService
    private var remoteStorageService: AnnotatoStorageService
    private let PersistenceManager: PersistenceManager

    init(PersistenceManager: PersistenceManager) {
        localStorageService = LocalStorage()
        remoteStorageService = FirebaseStorage()
        self.PersistenceManager = PersistenceManager
    }

    var delegate: AnnotatoStorageDelegate? {
        didSet {
            localStorageService.delegate = delegate
            remoteStorageService.delegate = delegate
        }
    }

    func uploadPdf(fileSystemUrl: URL, withName name: String, completion: @escaping (Document) -> Void) {
        guard let userId = AnnotatoAuth().currentUser?.uid else {
            AnnotatoLogger.error("When getting current user's ID", context: "OnlinePDFStorageManager::uploadPdf")
            return
        }

        let documentId = UUID()

        localStorageService.uploadPdf(fileSystemUrl: fileSystemUrl, withId: documentId)

        remoteStorageService.uploadPdf(fileSystemUrl: fileSystemUrl, withId: documentId)

        let document = Document(name: name, ownerId: userId, id: documentId)

        Task {
            guard let document = await self.PersistenceManager.createDocument(document: document) else {
                return
            }

            AnnotatoLogger.info("Created backend document entry: \(document)")
            completion(document)
        }
    }

    func deletePdf(document: Document, completion: @escaping (Document) -> Void) {
        localStorageService.deletePdf(document: document)
        remoteStorageService.deletePdf(document: document)

        Task {
            guard let document = await self.PersistenceManager.deleteDocument(document: document) else {
                return
            }

            AnnotatoLogger.info("Deleted backend document entry: \(document)")
            completion(document)
        }
    }
}
