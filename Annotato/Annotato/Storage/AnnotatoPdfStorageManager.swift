import Foundation
import AnnotatoSharedLibrary

class AnnotatoPdfStorageManager {
    private var localStorageService: AnnotatoStorageService
    private var remoteStorageService: AnnotatoStorageService
    private let api = RemoteDocumentsPersistence() // TODO: Replace with Persistence wrapper

    init() {
        localStorageService = LocalStorage()
        remoteStorageService = FirebaseStorage()
    }

    var delegate: AnnotatoStorageDelegate? {
        didSet {
            localStorageService.delegate = delegate
            remoteStorageService.delegate = delegate
        }
    }

    func uploadPdf(fileSystemUrl: URL, withName name: String, completion: @escaping (Document) -> Void) {
        guard let userId = AnnotatoAuth().currentUser?.uid else {
            AnnotatoLogger.error("When getting current user's ID", context: "AnnotatoPdfStorageManager::uploadPdf")
            return
        }

        let documentId = UUID()

        localStorageService.uploadPdf(fileSystemUrl: fileSystemUrl, withId: documentId, completion: { _ in })

        remoteStorageService.uploadPdf(fileSystemUrl: fileSystemUrl, withId: documentId) { remoteFileUrl in
            let document = Document(name: name, ownerId: userId, baseFileUrl: remoteFileUrl?.absoluteString, id: documentId)

            Task {
                guard let document = await self.api.createDocument(document: document) else {
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
            guard let document = await self.api.deleteDocument(document: document) else {
                return
            }

            AnnotatoLogger.info("Deleted backend document entry: \(document)")
            completion(document)
        }
    }
}
