import UIKit
import PDFKit

class DocumentPdfView: PDFView {
    private var viewModel: DocumentPdfViewModel

    @available(*, unavailable)
    required init(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    init(frame: CGRect, documentPdfViewModel: DocumentPdfViewModel) {
        self.viewModel = documentPdfViewModel
        super.init(frame: frame)
        self.autoScales = viewModel.autoScales
        self.document = viewModel.document
    }
}
