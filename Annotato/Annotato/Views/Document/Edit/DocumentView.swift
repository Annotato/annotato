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
            self, selector: #selector(handleVisiblePageChange(notification:)),
            name: Notification.Name.PDFViewVisiblePagesChanged, object: nil
        )
    }

    @objc
    private func handleVisiblePageChange(notification: Notification) {
        initializeAnnotationViewsForVisiblePages()
    }

    private func checkIfAnnotationIsInVisiblePages(
        anno: DocumentAnnotationViewModel,
        visiblePages: [PDFPage]
    ) -> Bool {
        guard let pageNumForAnnotation = anno.associatedPage.label else {
            return false
        }
        let visiblePagesIndex = visiblePages.map({ pdfPage -> String in
            guard let label = pdfPage.label else {
                return "-1"
            }
            return label
        })
        return visiblePagesIndex.contains(pageNumForAnnotation)
    }

    private func checkIfAnnoIsAlreadyInSubview(
        anno: DocumentAnnotationViewModel, subviews: [UIView]
    ) -> Bool {
        for subview in subviews {
            guard let annoSubview = subview as? DocumentAnnotationView else {
                continue
            }
            if annoSubview.viewModel === anno {
                return true
            }
        }
        return false
    }

    private func bringAnnoToFront(
        anno: DocumentAnnotationViewModel, subviews: [UIView]
    ) {
        for subview in subviews {
            guard let annoSubview = subview as? DocumentAnnotationView else {
                continue
            }
            if annoSubview.viewModel === anno {
                guard let documentViewParent = annoSubview.superview else {
                    return
                }
                documentViewParent.bringSubviewToFront(annoSubview)
            }
        }
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
        for annotation in documentViewModel.annotations {
            let view = DocumentAnnotationView(annotationViewModel: annotation)
            let annoShouldBeVisible = checkIfAnnotationIsInVisiblePages(anno: annotation, visiblePages: visiblePages)
            guard let documentView = pdfSubView.documentView else {
                continue
            }

            if annoShouldBeVisible {
                let annoIsAlreadyInSubview = checkIfAnnoIsAlreadyInSubview(
                    anno: annotation, subviews: documentView.subviews
                )
                if !annoIsAlreadyInSubview {
                    pdfSubView.documentView?.addSubview(view)
                } else {
                    // simply bring it to the front
                    bringAnnoToFront(
                        anno: annotation, subviews: documentView.subviews
                    )
                }
            }
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
        testFunc(mainViewTouchPoint: touchPoint)
    }

    private func testFunc(mainViewTouchPoint: CGPoint) {
        guard let pdfView = self.pdfView else {
            return
        }
        // This returns the page that the click occurred
        guard let pageClicked: PDFPage = pdfView.page(for: mainViewTouchPoint, nearest: true) else {
            return
        }
        print("pageClicked: \(pageClicked)")

        let pageSpacePoint = pdfView.convert(mainViewTouchPoint, to: pageClicked)
        print("page space point: \(pageSpacePoint)")

        let docViewSpacePoint = self.convert(mainViewTouchPoint, to: pdfView.documentView)
        print("entire pdfview space point: \(docViewSpacePoint)")

        let newAnnotationWidth = 200.0
        let docAnnoViewModel = DocumentAnnotationViewModel(
            associatedDocumentPdfViewModel: pdfView.viewModel,
            coordinatesInDocumentSpace: docViewSpacePoint,
            associatedPage: pageClicked,
            coordinatesInPageSpace: pageSpacePoint,
            width: newAnnotationWidth,
            parts: []
        )
        let annotation = DocumentAnnotationView(
            annotationViewModel: docAnnoViewModel
        )
        pdfView.documentView?.addSubview(annotation)
        print("-------------------------------------")
    }
}
