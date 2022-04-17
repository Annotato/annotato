import Foundation
import AnnotatoSharedLibrary

protocol AnnotatoRemoteStorageService {
    func getDownloadUrl(fileName: String) async -> URL?
    func uploadPdf(fileSystemUrl: URL, fileName: String)
    func deletePdf(fileName: String)
}
