import UIKit
import PDFKit

class DocumentView: UIView {
    private var documentViewModel: DocumentViewModel
    private var pdfView: DocumentPdfView?

    @available(*, unavailable)
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    init(frame: CGRect, documentViewModel: DocumentViewModel) {
        self.documentViewModel = documentViewModel
        super.init(frame: frame)

        self.layer.borderWidth = 2
        self.layer.borderColor = UIColor.black.cgColor

        addTapGestureRecognizer()
        initializePdfView()
        initializeAnnotationViews()
    }

    private func initializeAnnotationViews() {
        guard let pdfSubView = subviews.first(where: { subview in
            subview is DocumentPdfView
        }) else {
            return
        }
        guard let pdfSubView = pdfSubView as? DocumentPdfView else {
            return
        }

        for annotation in documentViewModel.annotations {
            let view = DocumentAnnotationView(annotationViewModel: annotation)
            pdfSubView.documentView?.addSubview(view)
        }
    }

    private func initializePdfView() {
        let view = DocumentPdfView(
            frame: self.frame,
            documentPdfViewModel: documentViewModel.pdfDocument
        )
        self.pdfView = view
        addSubview(view)
    }

    private func addTapGestureRecognizer() {
        isUserInteractionEnabled = true
        let gestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(didTap))
        addGestureRecognizer(gestureRecognizer)
    }

    @objc
    private func didTap(_ sender: UITapGestureRecognizer) {
        let touchPoint = sender.location(in: self)
        print("touch coordinates in view: \(touchPoint)")
        testFunc(mainViewTouchPoint: touchPoint)
    }

    private func testFunc(mainViewTouchPoint: CGPoint) {
        guard let pdfView = self.pdfView else {
            return
        }
        // This returns the page that the click occurred
        guard let pageClicked: PDFPage = pdfView.page(for: mainViewTouchPoint, nearest: true) else {
            print("no page")
            return
        }

        let pageSpacePoint = pdfView.convert(mainViewTouchPoint, to: pageClicked)
        print("page space point: \(pageSpacePoint)")

        let pdfViewSpacePoint = self.convert(mainViewTouchPoint, to: pdfView.documentView)
        print("entire pdfview space point: \(pdfViewSpacePoint)")

        let newAnnotationWidth = 200.0
        let docAnnoViewModel = DocumentAnnotationViewModel(
            associatedDocumentPdfViewModel: pdfView.viewModel,
            associatedPage: pageClicked,
            coordinatesInPageSpace: pageSpacePoint,
            width: newAnnotationWidth,
            parts: []
        )
        let annotation = DocumentAnnotationView(
            annotationViewModel: docAnnoViewModel
        )
        pdfView.documentView?.addSubview(annotation)
    }
}
