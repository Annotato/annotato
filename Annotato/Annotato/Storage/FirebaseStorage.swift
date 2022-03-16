import Firebase
import FirebaseStorage

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
                    "When trying to upload PDF with fileSystemUrl: \(fileSystemUrl). \(error.localizedDescription)",
                    context: "FirebaseStorage::uploadPdf"
                )
                self.delegate?.uploadDidFail(error)
                return
            }
            AnnotatoLogger.info("Uploaded PDF with fileSystemUrl: \(fileSystemUrl)")
            self.delegate?.uploadDidSucceed()

            pdfRef.downloadURL { url, error in
                if let error = error {
                    AnnotatoLogger.error(
                        "When getting URL of PDF with fileSystemUrl: \(fileSystemUrl). \(error.localizedDescription)",
                        context: "FirebaseStorage::uploadPdf")
                    return
                }
                completion(url!)
            }
        }
    }
}
