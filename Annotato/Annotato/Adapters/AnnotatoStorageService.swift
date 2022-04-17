import Foundation
import AnnotatoSharedLibrary

protocol AnnotatoStorageService {
    func getDownloadUrl(fileName: String) async -> URL?
    func uploadPdf(fileSystemUrl: URL, fileName: String)
    func deletePdf(fileName: String)
}
