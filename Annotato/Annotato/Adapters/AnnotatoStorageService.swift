import Foundation

protocol AnnotatoStorageService {
    var delegate: AnnotatoStorageDelegate? { get set }
    func uploadPdf(baseFileUrl: URL, withName name: String)
    func downloadPdf(destionationUrl: URL, withName name: String)
}
