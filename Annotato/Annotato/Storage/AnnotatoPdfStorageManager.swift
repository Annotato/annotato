import Foundation
import AnnotatoSharedLibrary

class AnnotatoPdfStorageManager {
    private var storageService: AnnotatoStorageService

    init() {
        storageService = FirebaseStorage()
    }

    var delegate: AnnotatoStorageDelegate? {
        get { storageService.delegate }
        set { storageService.delegate = newValue }
    }

    func uploadPdf(fileSystemUrl: URL, withName name: String) {
        storageService.uploadPdf(fileSystemUrl: fileSystemUrl, withName: name) { url in
            guard let userId = AnnotatoAuth().currentUser?.uid else {
                AnnotatoLogger.error("When getting current user's ID", context: "AnnotatoPdfStorageManager::uploadPdf")
                return
            }

            let document = Document(name: name, ownerId: userId, baseFileUrl: url.absoluteString)
            print(document.baseFileUrl)
            // TODO: ADD API CALL TO FLUENT
        }
    }
}
