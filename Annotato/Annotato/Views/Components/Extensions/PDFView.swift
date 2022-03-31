import PDFKit

extension PDFView {
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
