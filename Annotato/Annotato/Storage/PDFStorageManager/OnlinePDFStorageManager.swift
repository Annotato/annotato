import Foundation
import AnnotatoSharedLibrary

class OnlinePDFStorageManager: PDFStorageManager {
    private var localStorageService: AnnotatoStorageService
    private var remoteStorageService: AnnotatoStorageService
    private let persistenceService: PersistenceService

    init(persistenceService: PersistenceService) {
        localStorageService = LocalStorage()
        remoteStorageService = FirebaseStorage()
        self.persistenceService = persistenceService
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

        localStorageService.uploadPdf(fileSystemUrl: fileSystemUrl, withId: documentId, completion: { _ in })

        remoteStorageService.uploadPdf(fileSystemUrl: fileSystemUrl, withId: documentId) { url in
            let document = Document(name: name, ownerId: userId, baseFileUrl: url.absoluteString, id: documentId)

            Task {
                guard let document = await self.persistenceService.createDocument(document: document) else {
                    return
                }

                AnnotatoLogger.info("Created backend document entry: \(document)")
                completion(document)
            }
        }
    }

    func deletePdf(document: Document, completion: @escaping (Document) -> Void) {
        localStorageService.deletePdf(document: document)
        remoteStorageService.deletePdf(document: document)

        Task {
            guard let document = await self.persistenceService.deleteDocument(document: document) else {
                return
            }

            AnnotatoLogger.info("Deleted backend document entry: \(document)")
            completion(document)
        }
    }
}
