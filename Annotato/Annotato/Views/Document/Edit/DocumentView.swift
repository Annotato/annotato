import UIKit
import PDFKit
import Combine

class DocumentView: UIView {
    private var documentViewModel: DocumentViewModel
    private var cancellables: Set<AnyCancellable> = []

    private var pdfView: DocumentPdfView
    private var annotationViews: [AnnotationView]

    @available(*, unavailable)
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    init(frame: CGRect, documentViewModel: DocumentViewModel) {
        self.documentViewModel = documentViewModel
        self.annotationViews = []
        self.pdfView = DocumentPdfView(
            frame: .zero,
            documentPdfViewModel: documentViewModel.pdfDocument
        )

        super.init(frame: frame)
        self.layer.borderWidth = 2
        self.layer.borderColor = UIColor.black.cgColor

        addGestureRecognizers()
        addObservers()
        initializePdfView()
        setUpSubscribers()
        initializeInitialAnnotationViews()
    }

    private func initializeInitialAnnotationViews() {
        for annotation in documentViewModel.annotations {
            renderNewAnnotation(viewModel: annotation)
        }
    }

    private func initializePdfView() {
        addSubview(pdfView)
        pdfView.translatesAutoresizingMaskIntoConstraints = false
        pdfView.topAnchor.constraint(equalTo: topAnchor).isActive = true
        pdfView.bottomAnchor.constraint(equalTo: bottomAnchor).isActive = true
        pdfView.leftAnchor.constraint(equalTo: leftAnchor).isActive = true
        pdfView.rightAnchor.constraint(equalTo: rightAnchor).isActive = true
    }

    private func setUpSubscribers() {
        documentViewModel.$annotationToAdd.sink(receiveValue: { [weak self] annotationViewModel in
            guard let annotationViewModel = annotationViewModel else {
                return
            }
            self?.renderNewAnnotation(viewModel: annotationViewModel)
        }).store(in: &cancellables)
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

    private func addGestureRecognizers() {
        isUserInteractionEnabled = true
        let tapGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(didTap))
        addGestureRecognizer(tapGestureRecognizer)
    }

    @objc
    private func didTap(_ sender: UITapGestureRecognizer) {
        let touchPoint = sender.location(in: self)
        addAnnotation(at: touchPoint)
    }

    private func addAnnotation(at pointInDocument: CGPoint) {
        let pointInPdf = self.convert(pointInDocument, to: pdfView.documentView)
        documentViewModel.addAnnotation(center: pointInPdf)
    }

    private func renderNewAnnotation(viewModel: AnnotationViewModel) {
        let annotationView = AnnotationView(viewModel: viewModel)
        annotationViews.append(annotationView)
        pdfView.documentView?.addSubview(annotationView)
    }
}

// MARK: Display annotations when visible pages of pdf change
extension DocumentView {
    // Note: Subviews in PdfView get shifted to the back after scrolling away
    // for a certain distance, therefore they must be brought forward
    private func showAnnotationsOfVisiblePages() {
        let visiblePages = pdfView.visiblePages

        let annotationsToShow = annotationViews.filter({
            annotationIsInVisiblePages(annotation: $0, visiblePages: visiblePages)
        })
        for annotation in annotationsToShow {
            bringAnnotationToFront(annotation: annotation)
        }
    }

    private func annotationIsInVisiblePages(
        annotation: AnnotationView,
        visiblePages: [PDFPage]
    ) -> Bool {
        guard let centerInDocument = pdfView.documentView?.convert(annotation.center, to: self) else {
            return false
        }
        guard let pageContainingAnnotation = pdfView.page(for: centerInDocument, nearest: true) else {
            return false
        }
        return visiblePages.contains(pageContainingAnnotation)
    }

    private func bringAnnotationToFront(annotation: AnnotationView) {
        annotation.superview?.bringSubviewToFront(annotation)
    }
}
