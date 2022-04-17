import Foundation
import AnnotatoSharedLibrary

class PDFStorageManager {
    private var localStorageService: AnnotatoLocalStorageService
    private var remoteStorageService: AnnotatoRemoteStorageService

    init() {
        localStorageService = LocalStorage()
        remoteStorageService = FirebaseStorage()
    }

    func getLocalUrl(fileName: String) -> URL {
        localStorageService.getUrl(fileName: fileName)
    }

    func uploadPdf(fileSystemUrl: URL, fileName: String) {
        localStorageService.uploadPdf(fileSystemUrl: fileSystemUrl, fileName: fileName)

        remoteStorageService.uploadPdf(fileSystemUrl: fileSystemUrl, fileName: fileName)
    }

    func downloadPdfToLocalStorage(fileName: String) async {
        guard let downloadURL = await remoteStorageService.getDownloadUrl(fileName: fileName) else {
            AnnotatoLogger.error("Could not get download URL for document",
                                 context: "PDFStorageManager::downloadPdfToLocalStorage")
            return
        }

        guard let documentPDFData = try? await URLSessionHTTPService().get(url: downloadURL.absoluteString) else {
            AnnotatoLogger.error("Could not retrieve document PDF data using HTTP",
                                 context: "PDFStorageManager::downloadPdfToLocalStorage")
            return
        }

        localStorageService.uploadPdf(pdfData: documentPDFData, fileName: fileName)
    }

    func deletePdf(fileName: String) {
        localStorageService.deletePdf(fileName: fileName)

        remoteStorageService.deletePdf(fileName: fileName)
    }
}
