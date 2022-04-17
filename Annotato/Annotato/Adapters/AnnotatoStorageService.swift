import Foundation
import AnnotatoSharedLibrary

protocol AnnotatoStorageService {
    func getUrl(fileName: String)
    func uploadPdf(fileSystemUrl: URL, fileName: String)
    func uploadPdf(pdfData: Data, fileName: String)
    func deletePdf(fileName: String)
}
