import PDFKit
import AnnotatoSharedLibrary

class PdfPresenter {
    let autoScales = true
    let document: PDFDocument

    init(document: Document) {
        guard let pdfDocument = PDFDocument(url: document.localFileUrl) else {
            AnnotatoLogger.error("Could not load document")
            // TODO: Handle failed init more gracefully
            fatalError("No such document")
        }

        self.document = pdfDocument
        AnnotatoLogger.info("Loaded PDFDocument with document URL: \(String(describing: pdfDocument.documentURL))",
                            context: "PdfPresenter::init")
    }
}
