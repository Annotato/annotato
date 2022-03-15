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

    func uploadPdf(baseFileUrl: URL, withName name: String) {
        storageService.uploadPdf(baseFileUrl: baseFileUrl, withName: name)

    }

    func downloadPdf(destionationUrl: URL, withName name: String) {
        storageService.downloadPdf(destionationUrl: destionationUrl, withName: name)
    }
}
