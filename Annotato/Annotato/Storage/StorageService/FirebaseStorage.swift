import Firebase
import FirebaseStorage
import AnnotatoSharedLibrary

class FirebaseStorage: AnnotatoStorageService {
    private let storage = Storage.storage()
    private var storageRef: StorageReference {
        storage.reference()
    }

    func getDownloadUrl(fileName: String) async -> URL? {
        let pdfRef = storageRef.child(documentId.uuidString)
        do {
            return try await pdfRef.downloadURL()
        } catch {
            AnnotatoLogger.error("Could not get download URL for file \(fileName)",
                                 context: "FirebaseStorage::getUrl")
            return nil
        }
    }

    func uploadPdf(fileSystemUrl: URL, fileName: String) {
        let pdfRef = storageRef.child(fileName)

        _ = pdfRef.putFile(from: fileSystemUrl, metadata: nil) { _, error in
            if let error = error {
                AnnotatoLogger.error(
                    "When uploading PDF with fileSystemUrl: \(fileSystemUrl) to FB. \(error.localizedDescription)",
                    context: "FirebaseStorage::uploadPdf"
                )
                return
            }

            AnnotatoLogger.info("Uploaded to Firebase - PDF with fileSystemUrl: \(fileSystemUrl)")
        }
    }

    func deletePdf(fileName: String) {
        let pdfRef = storageRef.child(fileName)
        pdfRef.delete { error in
            if let error = error {
                AnnotatoLogger.error(
                    "When trying to delete PDF from firebase: \(fileName). \(error.localizedDescription)",
                    context: "FirebaseStorage::deletePdf"
                )
                return
            }

            AnnotatoLogger.info("Deleted PDF: \(fileName) from FB.")
        }
    }
}
