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

    func downloadPdfToLocalStorage(fileName: String) async -> Bool {
        guard let downloadURL = await remoteStorageService.getUrl(fileName: fileName) else {
            AnnotatoLogger.error("Could not get download URL for document",
                                 context: "PDFStorageManager::downloadPdfToLocalStorage")
            return false
        }

        guard let documentPDFData = try? await URLSessionHTTPService().get(url: downloadURL.absoluteString) else {
            AnnotatoLogger.error("Could not retrieve document PDF data using HTTP",
                                 context: "PDFStorageManager::downloadPdfToLocalStorage")
            return false
        }

        let wasPDFSavedLocally = localStorageService.uploadPdf(pdfData: documentPDFData, fileName: document.id.uuidString)
        guard wasPDFSavedLocally else {
            AnnotatoLogger.error("Could not save document PDF to local file system",
                                 context: "PDFStorageManager::downloadPdfToLocalStorage")
            return false
        }

        return true
    }

    func deletePdf(fileName: String) {
        localStorageService.deletePdf(fileName: fileName)

        remoteStorageService.deletePdf(fileName: fileName)
    }
}
