import Firebase
import FirebaseStorage
import AnnotatoSharedLibrary

class FirebaseStorage: AnnotatoStorageService {
    private let storage = Storage.storage()
    private var storageRef: StorageReference {
        storage.reference()
    }

    weak var delegate: AnnotatoStorageDelegate?

    func uploadPdf(
        fileSystemUrl: URL,
        withId documentId: UUID,
        completion: @escaping (URL) -> Void
    ) {
        let pdfRef = storageRef.child(documentId.uuidString)

        // swiftlint:disable closure_body_length
        _ = pdfRef.putFile(from: fileSystemUrl, metadata: nil) { _, error in
            if let error = error {
                AnnotatoLogger.error(
                    "When uploading PDF with fileSystemUrl: \(fileSystemUrl) to FB. \(error.localizedDescription)",
                    context: "FirebaseStorage::uploadPdf"
                )
                self.delegate?.uploadDidFail(error)
                return
            }
            AnnotatoLogger.info("Uploaded PDF with fileSystemUrl: \(fileSystemUrl) to FB")

            pdfRef.downloadURL { url, error in
                if let error = error {
                    AnnotatoLogger.error(
                        "When getting FB URL of PDF with fileSystemUrl: \(fileSystemUrl)." +
                        "\(error.localizedDescription)",
                        context: "FirebaseStorage::uploadPdf")
                    return
                }

                guard let url = url else {
                    AnnotatoLogger.error(
                        "Missing FB URL for PDF with fileSystemUrl: \(fileSystemUrl).",
                        context: "FirebaseStorage::uploadPdf")
                    return
                }

                completion(url)
                self.delegate?.uploadDidSucceed()
            }
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
}
