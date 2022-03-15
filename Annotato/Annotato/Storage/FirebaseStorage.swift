import Firebase
import FirebaseStorage

class FirebaseStorage: AnnotatoStorageService {
    private let storage = Storage.storage()

    weak var delegate: AnnotatoStorageDelegate?

    func uploadPdf(fileSystemUrl: URL, withName name: String) {
        let storageRef = storage.reference()
        let pdfRef = storageRef.child("\(name)")
        _ = pdfRef.putFile(from: fileSystemUrl, metadata: nil) { _, error in
            if let error = error {
                AnnotatoLogger.error(
                    "When trying to upload PDF with baseFileUrl: \(fileSystemUrl). \(error.localizedDescription)",
                    context: "FirebaseStorage::uploadPdf"
                )
                self.delegate?.uploadDidFail(error)
                return
            }
            AnnotatoLogger.info("Uploaded PDF with baseFileUrl: \(fileSystemUrl)")
            self.delegate?.uploadDidSucceed()
        }
    }

    func downloadPdf(destionationUrl: URL, withName name: String) {
        let storageRef = storage.reference()
        let pdfRef = storageRef.child("\(name)")
        _ = pdfRef.write(toFile: destionationUrl) { _, error in
            if let error = error {
                AnnotatoLogger.error(
                    "When trying to download PDF with name: \(name). \(error.localizedDescription)",
                    context: "FirebaseStorage::downloadPdf"
                )
                self.delegate?.uploadDidFail(error)
                return
            }
            AnnotatoLogger.info("Downloaded PDF with name: \(name)")
            self.delegate?.uploadDidSucceed()
        }
    }
}
