import UIKit
import PDFKit
import Combine

class DocumentView: UIView {
    private var documentViewModel: DocumentViewModel
    private var pdfView: DocumentPdfView?
    private var cancellables: Set<AnyCancellable> = []

    @available(*, unavailable)
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    init(frame: CGRect, documentViewModel: DocumentViewModel) {
        self.documentViewModel = documentViewModel
        super.init(frame: frame)

        self.layer.borderWidth = 2
        self.layer.borderColor = UIColor.black.cgColor

        addGestureRecognizers()
        addObservers()
        initializePdfView()
        setUpSubscriber()
        initializeInitialAnnotationViews()
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
        anno: AnnotationViewModel,
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
        anno: AnnotationViewModel, subviews: [UIView]
    ) -> Bool {
        for subview in subviews {
            guard let annoSubview = subview as? AnnotationView else {
                continue
            }
            if annoSubview.viewModel === anno {
                return true
            }
        }
        return false
    }

    private func bringAnnoToFront(
        anno: AnnotationViewModel, subviews: [UIView]
    ) {
        for subview in subviews {
            guard let annoSubview = subview as? AnnotationView else {
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
        guard let pdfSubView = pdfView else {
            return
        }
        guard let documentView = pdfSubView.documentView else {
            return
        }
        let visiblePages = pdfSubView.visiblePages
        for annotation in documentViewModel.annotations {
            let annoShouldBeVisible = checkIfAnnotationIsInVisiblePages(anno: annotation, visiblePages: visiblePages)

            if annoShouldBeVisible {
                let annoIsAlreadyInSubview = checkIfAnnoIsAlreadyInSubview(
                    anno: annotation, subviews: documentView.subviews
                )
                if !annoIsAlreadyInSubview {
                    documentViewModel.addAnnotation(
                        viewModel: annotation
                    )
                } else {
                    bringAnnoToFront(
                        anno: annotation, subviews: documentView.subviews
                    )
                }
            }
        }
    }

    /*
     This function needs to be present so that we don't run into a cycle
     when updating the view model using the addAnnotation function.
     Which means initially we cannot add to the subview using the
     addAnnotation function and must manually renderNewAnnotation directly
     here.
     Otherwise, there will be double of the initial objects, or could
     potentially run into a cycle, depending on how we call it.
     */
    func initializeInitialAnnotationViews() {
        guard let pdfSubView = pdfView else {
            return
        }
        guard let documentView = pdfSubView.documentView else {
            return
        }
        for annotation in documentViewModel.annotations {
            let annoIsAlreadyInSubview = checkIfAnnoIsAlreadyInSubview(
                anno: annotation, subviews: documentView.subviews
            )
            if !annoIsAlreadyInSubview {
                renderNewAnnotation(viewModel: annotation)
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

    private func addGestureRecognizers() {
        isUserInteractionEnabled = true
        let tapGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(didTap))
        addGestureRecognizer(tapGestureRecognizer)
    }

    @objc
    private func didTap(_ sender: UITapGestureRecognizer) {
        let touchPoint = sender.location(in: self)
        addAnnoToViewAndViewModel(mainViewTouchPoint: touchPoint)
    }

    private func addAnnoToViewAndViewModel(mainViewTouchPoint: CGPoint) {
        guard let pdfView = self.pdfView else {
            return
        }
        // This returns the page that the click occurred
        guard let pageClicked: PDFPage = pdfView.page(for: mainViewTouchPoint, nearest: true) else {
            return
        }

        let pageSpacePoint = pdfView.convert(mainViewTouchPoint, to: pageClicked)

        let docViewSpacePoint = self.convert(mainViewTouchPoint, to: pdfView.documentView)

        let newAnnotationWidth = 300.0
        let docAnnoViewModel = AnnotationViewModel(
            id: UUID(), originInDocumentSpace: docViewSpacePoint,
            associatedDocumentPdfViewModel: pdfView.viewModel,
            associatedPage: pageClicked,
            coordinatesInPageSpace: pageSpacePoint,
            width: newAnnotationWidth,
            parts: []
        )
        renderNewAnnotation(viewModel: docAnnoViewModel)
    }

    private func renderNewAnnotation(viewModel: AnnotationViewModel) {
        let annoView = AnnotationView(viewModel: viewModel)
        pdfView?.documentView?.addSubview(annoView)
    }

    private func setUpSubscriber() {
        documentViewModel.$annotationToAdd.sink(receiveValue: { [weak self] annotationViewModel in
            guard let annotationViewModel = annotationViewModel else {
                return
            }
            self?.renderNewAnnotation(viewModel: annotationViewModel)
        }).store(in: &cancellables)
    }
}
