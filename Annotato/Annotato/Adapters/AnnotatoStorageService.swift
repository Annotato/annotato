import Foundation
import AnnotatoSharedLibrary

protocol AnnotatoStorageService {
    var delegate: AnnotatoStorageDelegate? { get set }
    func uploadPdf(fileSystemUrl: URL, withName name: String, completion: @escaping (URL) -> Void)
    func deletePdf(document: Document, completion: @escaping () -> Void)
}
