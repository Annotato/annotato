import Firebase
import FirebaseStorage
import AnnotatoSharedLibrary

class FirebaseStorage: AnnotatoStorageService {
    private let storage = Storage.storage()
    private var storageRef: StorageReference {
        storage.reference()
    }

    weak var delegate: AnnotatoStorageDelegate?

    func uploadPdf(fileSystemUrl: URL, withName name: String, completion: @escaping (URL) -> Void) {
        let pdfRef = storageRef.child("\(name)")
        _ = pdfRef.putFile(from: fileSystemUrl, metadata: nil) { _, error in
            if let error = error {
                AnnotatoLogger.error(
                    "When trying to upload PDF with fileSystemUrl: \(fileSystemUrl) to firebase. \(error.localizedDescription)",
                    context: "FirebaseStorage::uploadPdf"
                )
                self.delegate?.uploadDidFail(error)
                return
            }
            AnnotatoLogger.info("Uploaded PDF with fileSystemUrl: \(fileSystemUrl) to firebase")

            pdfRef.downloadURL { url, error in
                if let error = error {
                    AnnotatoLogger.error(
                        "When getting firebase URL of PDF with fileSystemUrl: \(fileSystemUrl). \(error.localizedDescription)",
                        context: "FirebaseStorage::uploadPdf")
                    return
                }

                guard let url = url else {
                    AnnotatoLogger.error(
                        "Missing firebase URL for PDF with fileSystemUrl: \(fileSystemUrl).",
                        context: "FirebaseStorage::uploadPdf")
                    return
                }

                completion(url)
                self.delegate?.uploadDidSucceed()
            }
        }
    }

    func deletePdf(document: Document, completion: @escaping () -> Void) {
        let pdfRef = storageRef.child("\(document.name)")
        pdfRef.delete { error in
            if let error = error {
                AnnotatoLogger.error(
                    "When trying to delete PDF from firebase: \(document). \(error.localizedDescription)",
                    context: "FirebaseStorage::deletePdf"
                )
                self.delegate?.deleteDidFail(error)
                return
            }
            
            AnnotatoLogger.info("Deleted PDF: \(document) from firebase.")
            completion()
        }
    }
}