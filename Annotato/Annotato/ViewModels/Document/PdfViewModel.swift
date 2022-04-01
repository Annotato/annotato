import PDFKit
import AnnotatoSharedLibrary

class PdfViewModel {
    let autoScales = true
    let document: PDFDocument

    init(document: Document) {
        let documentUrl: URL

        if let remoteFileUrlString = document.baseFileUrl,
           let remoteFileUrl = URL(string: remoteFileUrlString) {
            documentUrl = remoteFileUrl
        } else {
            documentUrl = document.localFileUrl
        }

        guard let document = PDFDocument(url: documentUrl) else {
            // TODO: Handle failed init gracefully
            fatalError("No such document")
        }

        self.document = document
    }
}
