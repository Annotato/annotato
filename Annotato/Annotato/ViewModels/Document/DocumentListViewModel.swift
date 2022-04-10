import Foundation
import AnnotatoSharedLibrary

class DocumentListViewModel {
    private let pdfStorageManager = PDFStorageManager()

    func importDocument(selectedFileUrl: URL, completion: @escaping (Document?) -> Void) {
        let doesFileExist = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first != nil
        guard doesFileExist else {
            return
        }

        guard let ownerId = AnnotatoAuth().currentUser?.uid else {
            return
        }

        Task {
            let document = Document(name: selectedFileUrl.lastPathComponent, ownerId: ownerId)
            pdfStorageManager.uploadPdf(
                fileSystemUrl: selectedFileUrl, fileName: document.id.uuidString
            )

            let createdDocument = await AnnotatoPersistenceWrapper
                .currentPersistenceManager
                .createDocument(document: document)

            completion(createdDocument)
        }
    }
}
