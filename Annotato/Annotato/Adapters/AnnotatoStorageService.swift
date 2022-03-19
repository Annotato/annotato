import Foundation
import AnnotatoSharedLibrary

protocol AnnotatoStorageService {
    var delegate: AnnotatoStorageDelegate? { get set }
    func uploadPdf(fileSystemUrl: URL, withName name: String,
                   withId documentId: UUID, completion: @escaping (URL) -> Void)
    func deletePdf(document: Document, completion: @escaping () -> Void)
}
