import Foundation

protocol AnnotatoLocalStorageService {
    func getUrl(fileName: String) -> URL
    func uploadPdf(fileSystemUrl: URL, fileName: String)
    func uploadPdf(pdfData: Data, fileName: String)
    func deletePdf(fileName: String)
}
