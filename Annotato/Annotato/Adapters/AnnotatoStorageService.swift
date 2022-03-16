import Foundation

protocol AnnotatoStorageService {
    var delegate: AnnotatoStorageDelegate? { get set }
    func uploadPdf(fileSystemUrl: URL, withName name: String, completion: @escaping (URL) -> Void)
}
