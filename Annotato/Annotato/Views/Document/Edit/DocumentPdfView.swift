import UIKit
import PDFKit

class DocumentPdfView: PDFView {
    private(set) var presenter: PdfPresenter

    @available(*, unavailable)
    required init(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    init(frame: CGRect, pdfPresenter: PdfPresenter) {
        self.presenter = pdfPresenter
        super.init(frame: frame)
        self.autoScales = presenter.autoScales
        self.document = presenter.document
    }
}
