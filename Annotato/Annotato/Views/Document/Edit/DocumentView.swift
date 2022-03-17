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
        print("visible pages changed")
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
                print("same instance of view model is already in view")
                return true
            }
        }
        return false
    }

    private func checkIfAnnoIsBlocked(
        anno: DocumentAnnotationViewModel, subviews: [UIView]
    ) {
        for subview in subviews {
            guard let annoSubview = subview as? DocumentAnnotationView else {
                continue
            }
            if annoSubview.viewModel === anno {
                let isBlocked = annoSubview.isHidden
                print("isBlocked: \(isBlocked)")
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

                }
            } else {
                // The annotation should not be visible
                let annoIsAlreadyInSubview = checkIfAnnoIsAlreadyInSubview(
                    anno: annotation, subviews: documentView.subviews
                )
                let annoIsHidden = checkIfAnnoIsBlocked(
                    anno: annotation, subviews: documentView.subviews
                )
                // Remove it from the subview if it is there
                if annoIsAlreadyInSubview {
                    print("anno should not be visible but is in subview")
                    // TODO: Implement removing subviews if they are out of view.
                    // It needs to be done from the annotation view itself I think
                    // by calling removeFromSuperView()

                } else {
                    print("anno is not in subview and is not visible")
                }
            }
        }
        print("-------------------------------------")
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
