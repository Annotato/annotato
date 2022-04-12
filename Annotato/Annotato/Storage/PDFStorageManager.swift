import Foundation
import AnnotatoSharedLibrary

class PDFStorageManager {
    private var localStorageService: AnnotatoStorageService
    private var remoteStorageService: AnnotatoStorageService

    init() {
        localStorageService = LocalStorage()
        remoteStorageService = FirebaseStorage()
    }

    func uploadPdf(fileSystemUrl: URL, fileName: String) {
        localStorageService.uploadPdf(fileSystemUrl: fileSystemUrl, fileName: fileName)

        remoteStorageService.uploadPdf(fileSystemUrl: fileSystemUrl, fileName: fileName)
    }

    func deletePdf(fileName: String) {
        localStorageService.deletePdf(fileName: fileName)

        remoteStorageService.deletePdf(fileName: fileName)
    }
}
