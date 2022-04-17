import Foundation
import AnnotatoSharedLibrary

class LocalStorage: AnnotatoLocalStorageService {
    var appDocumentsDirectory: URL {
        FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)[0]
    }

    func getUrl(fileName: String) -> URL {
        appDocumentsDirectory.appendingPathComponent(fileName).appendingPathExtension(for: .pdf)
    }

    func uploadPdf(fileSystemUrl: URL, fileName: String) {
        do {
            let urlInDocumentsDirectory = getUrl(fileName: fileName)

            try FileManager.default.copyItem(at: fileSystemUrl, to: urlInDocumentsDirectory)

            AnnotatoLogger.info("Uploaded to local storage - PDF with fileSystemUrl: \(fileSystemUrl)")
        } catch {
            AnnotatoLogger.error("When trying to upload PDF. \(error.localizedDescription)",
                                 context: "LocalStorage::uploadPdf")
        }
    }

    func uploadPdf(pdfData: Data, fileName: String) {
        let urlInDocumentsDirectory = getUrl(fileName: fileName)

       FileManager.default.createFile(atPath: urlInDocumentsDirectory.path, contents: pdfData)
    }

    func deletePdf(fileName: String) {
        do {
            let urlInDocumentsDirectory = getUrl(fileName: fileName)

            try FileManager.default.removeItem(at: urlInDocumentsDirectory)

            AnnotatoLogger.info("Deleted PDF: \(fileName) from local documents directory.")
        } catch {
            AnnotatoLogger.error("When trying to delete PDF. \(error.localizedDescription)",
                                 context: "LocalStorage::deletePdf")
        }
    }
}
