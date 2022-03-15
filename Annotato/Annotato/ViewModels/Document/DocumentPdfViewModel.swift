import UIKit
import PDFKit

class DocumentPdfViewModel {

    let autoScales = true
    let document: PDFDocument

    init(baseFileUrl: URL) {
        guard let document = PDFDocument(url: baseFileUrl) else {
            fatalError("No such document")
        }
        self.document = document
    }
}
