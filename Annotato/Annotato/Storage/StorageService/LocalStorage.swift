import Foundation
import AnnotatoSharedLibrary

class LocalStorage: AnnotatoStorageService {
    weak var delegate: AnnotatoStorageDelegate?

    var appDocumentsDirectory: URL {
        FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)[0]
    }

    func uploadPdf(fileSystemUrl: URL, withId documentId: UUID, completion: @escaping (URL) -> Void) {
        do {
            let urlInDocumentsDirectory = appDocumentsDirectory
                .appendingPathComponent(documentId.uuidString)
                .appendingPathExtension(for: .pdf)

            try FileManager.default.copyItem(at: fileSystemUrl, to: urlInDocumentsDirectory)

            AnnotatoLogger.info("Uploaded PDF with fileSystemUrl: \(fileSystemUrl) to local documents directory")
            delegate?.uploadDidSucceed()
        } catch {
            AnnotatoLogger.error("When trying to upload PDF. \(error.localizedDescription)",
                                 context: "LocalStorage::uploadPdf")
            delegate?.uploadDidFail(error)
        }
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
