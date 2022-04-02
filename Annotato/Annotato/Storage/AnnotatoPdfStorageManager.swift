import Foundation
import AnnotatoSharedLibrary

protocol AnnotatoPdfStorageManager {
    func uploadPdf(fileSystemUrl: URL, withName name: String, completion: @escaping (Document) -> Void)
    func deletePdf(document: Document, completion: @escaping (Document) -> Void)
}
