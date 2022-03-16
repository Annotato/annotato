import CoreGraphics
import PDFKit

class DocumentAnnotationViewModel {
    private(set) var parts: [DocumentAnnotationPartViewModel]
    private(set) var width: Double

    unowned var associatedDocumentPdfViewModel: DocumentPdfViewModel?
    var associatedDocument: PDFDocument
    var associatedPage: PDFPage
    var coordinatesInPageSpace: CGPoint

    init(
        associatedDocumentPdfViewModel: DocumentPdfViewModel,
        associatedPage: PDFPage,
        coordinatesInPageSpace: CGPoint,
        width: Double,
        parts: [DocumentAnnotationPartViewModel]
    ) {
        self.associatedDocumentPdfViewModel = associatedDocumentPdfViewModel
        self.associatedDocument = associatedDocumentPdfViewModel.document
        self.associatedPage = associatedPage
        self.coordinatesInPageSpace = coordinatesInPageSpace

        self.width = width
        self.parts = parts
        if self.parts.isEmpty {
            self.parts.append(DocumentAnnotationTextViewModel(
                content: "", height: 50.0, annotationType: .plainText))
        }
    }

    var height: Double {
        self.parts.reduce(0, {accHeight, nextPart in
            accHeight + nextPart.height
        })
    }

    var isNew: Bool {
        self.parts.count == 1 && self.parts[0].content.isEmpty
    }

    var startingAnnotationType: AnnotationType? {
        isNew ? self.parts[0].annotationType : nil
    }

    func updateLocation(documentViewPoint: CGPoint, parentView: UIView?) {
        guard let parentView = parentView else {
            return
        }
        guard let pdfView = parentView.superview?.superview
        as? DocumentPdfView else {
            return
        }

        // Get coordinates in terms of the visible view page space
        let visibleViewCoordinates = parentView.convert(
            documentViewPoint, to: parentView.superview?.superview)

        // Get the current page that this annotation is at
        guard let currPage = pdfView.page(
            for: visibleViewCoordinates, nearest: true) else {
            return
        }
        // Get the page space coordinates
        let pageSpaceCoordinates = pdfView.convert(visibleViewCoordinates, to: currPage)

        // Assign all the new values to update
        self.associatedPage = currPage
        self.coordinatesInPageSpace = pageSpaceCoordinates
        print("document view coord: \(documentViewPoint)")
        print("visible view coord: \(visibleViewCoordinates)")
        print("currPage: \(currPage)")
        print("coord in page space: \(pageSpaceCoordinates)")
        print("----------------------------------")
    }
}
