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
            self, selector: #selector(handleVisiblePageChange(notification:)),
            name: Notification.Name.PDFViewVisiblePagesChanged, object: nil
        )
    }

    @objc
    private func handleVisiblePageChange(notification: Notification) {
        print("visible pages changed")
        showAnnotationViewsOfVisiblePages()
    }

    private func annotationIsInVisiblePages(
        annotation: AnnotationView,
        visiblePages: [PDFPage]
    ) -> Bool {
        let visiblePagesIndex = visiblePages.map({ pdfPage -> String in
            guard let label = pdfPage.label else {
                return "-1"
            }
            return label
        })
        return visiblePagesIndex.contains(annotation.pageNum)
    }

    private func bringAnnotationToFront(
        annotation: AnnotationView
    ) {
        annotation.superview?.bringSubviewToFront(annotation)
    }

    private func showAnnotationViewsOfVisiblePages() {
        guard let pdfSubView = pdfView else {
            return
        }
        let visiblePages = pdfSubView.visiblePages
        print("There are \(annotationViews.count) annotation views.")
        for annotationView in annotationViews {
            let annotationShouldBeVisible = annotationIsInVisiblePages(
                annotation: annotationView, visiblePages: visiblePages
            )
            if annotationShouldBeVisible {
                bringAnnotationToFront(annotation: annotationView)
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
        for annotation in documentViewModel.annotations {
            print("an annotation")
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
        guard let pageNum: String = pageClicked.label else {
            return
        }
        let docViewSpacePoint = self.convert(mainViewTouchPoint, to: pdfView.documentView)
        documentViewModel.addAnnotation(
            center: docViewSpacePoint,
            pageNum: pageNum
        )
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
