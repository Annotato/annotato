import Foundation
import AnnotatoSharedLibrary

class LocalStorage: AnnotatoStorageService {
    var appDocumentsDirectory: URL {
        FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)[0]
    }

    func uploadPdf(fileSystemUrl: URL, fileName: String) {
        do {
            let urlInDocumentsDirectory = appDocumentsDirectory
                .appendingPathComponent(fileName)
                .appendingPathExtension(for: .pdf)

            try FileManager.default.copyItem(at: fileSystemUrl, to: urlInDocumentsDirectory)

            AnnotatoLogger.info("Uploaded to local storage - PDF with fileSystemUrl: \(fileSystemUrl)")
        } catch {
            AnnotatoLogger.error("When trying to upload PDF. \(error.localizedDescription)",
                                 context: "LocalStorage::uploadPdf")
        }
    }

    /// Returns whether the PDF data was successfully written to the documents directory.
    func uploadPdf(pdfData: Data, fileName: String) -> Bool {
        let urlInDocumentsDirectory = getUrlInDocumentsDirectory(fileName: fileName)

        return FileManager.default.createFile(atPath: urlInDocumentsDirectory.path, contents: pdfData)
    }

    func deletePdf(fileName: String) {
        do {
            let urlInDocumentsDirectory = getUrlInDocumentsDirectory(fileName: fileName)

            try FileManager.default.removeItem(at: urlInDocumentsDirectory)

            AnnotatoLogger.info("Deleted PDF: \(fileName) from local documents directory.")
        } catch {
            AnnotatoLogger.error("When trying to delete PDF. \(error.localizedDescription)",
                                 context: "LocalStorage::deletePdf")
        }
    }

    private func getUrlInDocumentsDirectory(fileName: String) -> URL {
        appDocumentsDirectory
            .appendingPathComponent(fileName)
            .appendingPathExtension(for: .pdf)
    }
}
