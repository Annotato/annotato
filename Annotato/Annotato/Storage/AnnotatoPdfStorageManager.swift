import Foundation
import AnnotatoSharedLibrary

class AnnotatoPdfStorageManager {
    private var storageService: AnnotatoStorageService
    private let api = RemoteDocumentsPersistence()

    init() {
        storageService = FirebaseStorage()
    }

    var delegate: AnnotatoStorageDelegate? {
        get { storageService.delegate }
        set { storageService.delegate = newValue }
    }

    func uploadPdf(fileSystemUrl: URL, withName name: String, completion: @escaping (Document) -> Void) {
        let documentId = UUID()

        storageService.uploadPdf(fileSystemUrl: fileSystemUrl, withName: name, withId: documentId) { url in
            guard let userId = AnnotatoAuth().currentUser?.uid else {
                AnnotatoLogger.error("When getting current user's ID", context: "AnnotatoPdfStorageManager::uploadPdf")
                return
            }

            let document = Document(name: name, ownerId: userId, baseFileUrl: url.absoluteString, id: documentId)

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
        storageService.deletePdf(document: document) {
            Task {
                guard let document = await self.api.deleteDocument(document: document) else {
                    return
                }

                AnnotatoLogger.info("Deleted backend document entry: \(document)")
                completion(document)
            }
        }
    }
}
