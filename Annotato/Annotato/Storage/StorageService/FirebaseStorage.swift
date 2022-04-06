import Firebase
import FirebaseStorage
import AnnotatoSharedLibrary

class FirebaseStorage: AnnotatoStorageService {
    private let storage = Storage.storage()
    private var storageRef: StorageReference {
        storage.reference()
    }

    weak var delegate: AnnotatoStorageDelegate?

    func uploadPdf(fileSystemUrl: URL, withId documentId: UUID) {
        let pdfRef = storageRef.child(documentId.uuidString)

        _ = pdfRef.putFile(from: fileSystemUrl, metadata: nil) { _, error in
            if let error = error {
                AnnotatoLogger.error(
                    "When uploading PDF with fileSystemUrl: \(fileSystemUrl) to FB. \(error.localizedDescription)",
                    context: "FirebaseStorage::uploadPdf"
                )
                self.delegate?.uploadDidFail(error)
                return
            }

            AnnotatoLogger.info("Uploaded to Firebase - PDF with fileSystemUrl: \(fileSystemUrl)")
            self.delegate?.uploadDidSucceed()
        }
    }

    func deletePdf(document: Document) {
        let pdfRef = storageRef.child(document.id.uuidString)
        pdfRef.delete { error in
            if let error = error {
                AnnotatoLogger.error(
                    "When trying to delete PDF from firebase: \(document). \(error.localizedDescription)",
                    context: "FirebaseStorage::deletePdf"
                )
                self.delegate?.deleteDidFail(error)
                return
            }

            AnnotatoLogger.info("Deleted PDF: \(document) from FB.")
        }
    }

    func getDownloadURL(documentId: UUID) async -> URL? {
        let pdfRef = storageRef.child(documentId.uuidString)
        do {
            return try await pdfRef.downloadURL()
        } catch {
            AnnotatoLogger.error("Could not get download URL for document with ID \(documentId)",
                                 context: "FirebaseStorage::getDownloadURL")
            return nil
        }
    }
}
