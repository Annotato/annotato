import Foundation

class AnnotatoStorage {
    private var storageService: AnnotatoStorageService

    init() {
        storageService = FirebaseStorage()
    }

    var delegate: AnnotatoStorageDelegate? {
        get { storageService.delegate }
        set { storageService.delegate = newValue }
    }

    func uploadPdf(fileSystemUrl: URL, withName name: String) {
        storageService.uploadPdf(fileSystemUrl: fileSystemUrl, withName: name)

    }

    func downloadPdf(destionationUrl: URL, withName name: String) {
        storageService.downloadPdf(destionationUrl: destionationUrl, withName: name)
    }
}
