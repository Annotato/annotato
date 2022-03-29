import UIKit
import PDFKit

class DocumentPdfView: PDFView {
    private(set) var viewModel: PdfViewModel

    @available(*, unavailable)
    required init(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    init(frame: CGRect, documentPdfViewModel: PdfViewModel) {
        self.viewModel = documentPdfViewModel
        super.init(frame: frame)
        self.autoScales = viewModel.autoScales
        self.document = viewModel.document
    }
}

extension DocumentPdfView {
    func visiblePagesContains(view: UIView) -> Bool {
        guard let centerInDocument = self.documentView?.convert(view.center, to: self) else {
            return false
        }
        guard let pageContainingView = self.page(for: centerInDocument, nearest: true) else {
            return false
        }
        return self.visiblePages.contains(pageContainingView)
    }
}
