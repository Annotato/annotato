import Foundation
import AnnotatoSharedLibrary

class LocalStorage: AnnotatoStorageService {
    weak var delegate: AnnotatoStorageDelegate?

    var appDocumentsDirectory: URL {
        FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)[0]
    }

    func uploadPdf(fileSystemUrl: URL, withId documentId: UUID) {
        do {
            let urlInDocumentsDirectory = appDocumentsDirectory
                .appendingPathComponent(documentId.uuidString)
                .appendingPathExtension(for: .pdf)

            try FileManager.default.copyItem(at: fileSystemUrl, to: urlInDocumentsDirectory)

            AnnotatoLogger.info("Uploaded to local storage - PDF with fileSystemUrl: \(fileSystemUrl)")
            delegate?.uploadDidSucceed()
        } catch {
            AnnotatoLogger.error("When trying to upload PDF. \(error.localizedDescription)",
                                 context: "LocalStorage::uploadPdf")
            delegate?.uploadDidFail(error)
        }
    }

    /// Returns whether the PDF data was successfully written to the documents directory.
    func uploadPdf(pdfData: Data, withId documentId: UUID) -> Bool {
        let urlInDocumentsDirectory = appDocumentsDirectory
            .appendingPathComponent(documentId.uuidString)
            .appendingPathExtension(for: .pdf)

        return FileManager.default.createFile(atPath: urlInDocumentsDirectory.path, contents: pdfData)
    }

    func deletePdf(document: Document) {
        do {
            try FileManager.default.removeItem(at: document.localFileUrl)

            AnnotatoLogger.info("Deleted PDF: \(document) from local documents directory.")
            delegate?.deleteDidSucceed()
        } catch {
            AnnotatoLogger.error("When trying to delete PDF. \(error.localizedDescription)",
                                 context: "LocalStorage::deletePdf")
            delegate?.deleteDidFail(error)
        }
    }
}
