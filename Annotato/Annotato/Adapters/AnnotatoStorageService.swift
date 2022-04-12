import Foundation
import AnnotatoSharedLibrary

protocol AnnotatoStorageService {
    func uploadPdf(fileSystemUrl: URL, fileName: String)
    func deletePdf(fileName: String)
}
