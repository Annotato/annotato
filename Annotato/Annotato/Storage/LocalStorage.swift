import Foundation
import AnnotatoSharedLibrary

class LocalStorage: AnnotatoStorageService {
    weak var delegate: AnnotatoStorageDelegate?

    var appDocumentsDirectory: URL {
        FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)[0]
    }

    func uploadPdf(
        fileSystemUrl: URL,
        withName name: String,
        withId documentId: UUID,
        completion: @escaping (URL) -> Void
    ) {
        do {
            let urlInDocumentsDirectory = appDocumentsDirectory
                .appendingPathComponent(documentId.uuidString)
                .appendingPathExtension(for: .pdf)

            try FileManager.default.copyItem(at: fileSystemUrl, to: urlInDocumentsDirectory)

            completion(urlInDocumentsDirectory)
        } catch {
            AnnotatoLogger.error("When trying to upload PDF. \(error.localizedDescription)",
                                 context: "LocalStorage::uploadPdf")
        }
    }

    func deletePdf(document: Document, completion: @escaping () -> Void) {
        do {
            try FileManager.default.removeItem(at: document.localFileUrl)
        } catch {
            AnnotatoLogger.error("When trying to delete PDF. \(error.localizedDescription)",
                                 context: "LocalStorage::deletePdf")
        }
    }
}
