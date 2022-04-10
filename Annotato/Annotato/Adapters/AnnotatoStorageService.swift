import Foundation
import AnnotatoSharedLibrary

protocol AnnotatoStorageService {
    var delegate: AnnotatoStorageDelegate? { get set }
    func uploadPdf(fileSystemUrl: URL, fileName: String)
    func deletePdf(fileName: String)
}
