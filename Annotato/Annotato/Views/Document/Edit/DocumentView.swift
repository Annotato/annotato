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
        addObservers()
        initializePdfView()
        initializeAnnotationViewsForVisiblePages()
    }

    private func addObservers() {
        NotificationCenter.default.addObserver(
            self, selector: #selector(handlePageChange(notification:)),
            name: Notification.Name.PDFViewPageChanged, object: nil
        )
    }

    @objc
    private func handlePageChange(notification: Notification) {
        print("changed pages")
    }

    private func initializeAnnotationViewsForVisiblePages() {
        guard let pdfSubView = subviews.first(where: { subview in
            subview is DocumentPdfView
        }) else {
            return
        }
        guard let pdfSubView = pdfSubView as? DocumentPdfView else {
            return
        }
        let visiblePages = pdfSubView.visiblePages
        print(visiblePages)
        print("-------------------------------------")
        for annotation in documentViewModel.annotations {
            let view = DocumentAnnotationView(annotationViewModel: annotation)
            print(annotation.associatedPage)
            // MARK: Bug here. Need to find a way to compare PDFPages accurately.
            // Different instances of the same file will have different memory
            // locations
            if visiblePages.contains(annotation.associatedPage) {
                // Then we should add it to the subview
                pdfSubView.documentView?.addSubview(view)
            } else {
                // we should remove it from the subview if it is there, to avoid
                // memory leak
                if subviews.contains(view) {
                    print("removing a view that is out of the visible pages")
                    // TODO: Implement removing subviews if they are out of view.
                    // It needs to be done from the annotation view itself I think
                    // by calling removeFromSuperView()
                } else {
                    print("subviews doesn't contain it, but it is not visible so not added")
                }
            }
        }
    }

    /*
     Might not be needed in the future
     */
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
