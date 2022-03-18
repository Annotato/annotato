import UIKit
import PDFKit
import Combine

class DocumentView: UIView {
    private var documentViewModel: DocumentViewModel
    private var cancellables: Set<AnyCancellable> = []

    private var pdfView: DocumentPdfView?
    private var annotationViews: [AnnotationView]

    @available(*, unavailable)
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    init(frame: CGRect, documentViewModel: DocumentViewModel) {
        self.documentViewModel = documentViewModel
        self.annotationViews = []

        super.init(frame: frame)
        self.layer.borderWidth = 2
        self.layer.borderColor = UIColor.black.cgColor

        addGestureRecognizers()
        addObservers()
        initializePdfView()
        setUpSubscriber()
        initializeInitialAnnotationViews()
    }

    private func addObservers() {
        NotificationCenter.default.addObserver(
            self, selector: #selector(didChangeVisiblePages(notification:)),
            name: Notification.Name.PDFViewVisiblePagesChanged, object: nil
        )
    }

    @objc
    private func didChangeVisiblePages(notification: Notification) {
        showAnnotationsOfVisiblePages()
    }

    private func annotationIsInVisiblePages(
        annotation: AnnotationView,
        visiblePages: [PDFPage]
    ) -> Bool {
        let visiblePageNumbers = visiblePages.compactMap({ $0.pageRef?.pageNumber })
        return visiblePageNumbers.contains(annotation.pageNumber)
    }

    private func bringAnnotationToFront(
        annotation: AnnotationView
    ) {
        annotation.superview?.bringSubviewToFront(annotation)
    }

    private func showAnnotationsOfVisiblePages() {
        guard let pdfSubView = pdfView else {
            return
        }
        let visiblePages = pdfSubView.visiblePages
        for annotationView in annotationViews {
            let annotationShouldBeVisible = annotationIsInVisiblePages(
                annotation: annotationView, visiblePages: visiblePages
            )
            if annotationShouldBeVisible {
                bringAnnotationToFront(annotation: annotationView)
            }
        }
    }

    func initializeInitialAnnotationViews() {
        for annotation in documentViewModel.annotations {
            renderNewAnnotation(viewModel: annotation)
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
        addAnnotation(touchPoint: touchPoint)
    }

    private func addAnnotation(touchPoint: CGPoint) {
        guard let pdfView = self.pdfView else {
            return
        }
        guard let pageClicked = pdfView.page(for: touchPoint, nearest: true) else {
            return
        }
        guard let pageNumber = pageClicked.pageRef?.pageNumber else {
            return
        }
        let pointInPdf = self.convert(touchPoint, to: pdfView.documentView)
        documentViewModel.addAnnotation(center: pointInPdf, pageNumber: pageNumber)
    }

    private func renderNewAnnotation(viewModel: AnnotationViewModel) {
        let annotationView = AnnotationView(viewModel: viewModel)
        annotationViews.append(annotationView)
        pdfView?.documentView?.addSubview(annotationView)
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
