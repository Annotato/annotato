import PDFKit
import AnnotatoSharedLibrary

class PdfViewModel {
    let autoScales = true
    let document: PDFDocument

    init(document: Document) {
        var pdfDocument = PDFDocument(url: document.localFileUrl)

        if pdfDocument == nil,
           let remoteFileUrlString = document.baseFileUrl,
           let remoteFileUrl = URL(string: remoteFileUrlString) {
            pdfDocument = PDFDocument(url: remoteFileUrl)
        }

        guard let pdfDocument = pdfDocument else {
            AnnotatoLogger.error("Could not load document")
            // TODO: Handle failed init more gracefully
            fatalError("No such document")
        }

        self.document = pdfDocument
    }
}
