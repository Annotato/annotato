import UIKit
import PDFKit
import Combine
import AnnotatoSharedLibrary

class DocumentView: UIView {
    private var viewModel: DocumentViewModel
    private var cancellables: Set<AnyCancellable> = []

    private var pdfView: DocumentPdfView
    private var annotationViews: [AnnotationView]
    private var selectionBoxView: UIView?

    @available(*, unavailable)
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    init(frame: CGRect, documentViewModel: DocumentViewModel) {
        self.viewModel = documentViewModel
        self.annotationViews = []
        self.pdfView = DocumentPdfView(
            frame: .zero,
            documentPdfViewModel: documentViewModel.pdfDocument
        )

        super.init(frame: frame)

        addGestureRecognizers()
        addObservers()
        initializePdfView()
        setUpSubscribers()
        initializeInitialAnnotationViews()
    }

    private func initializeInitialAnnotationViews() {
        for annotation in viewModel.annotations {
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
        viewModel.$addedAnnotation.sink(receiveValue: { [weak self] addedAnnotation in
            guard let addedAnnotation = addedAnnotation else {
                return
            }

            DispatchQueue.main.async {
                self?.renderNewAnnotation(viewModel: addedAnnotation)
            }
        }).store(in: &cancellables)

        viewModel.$selectionBoxFrame.sink(receiveValue: { [weak self] newSelectionBoxFrame in
            guard let newSelectionBoxFrame = newSelectionBoxFrame else {
                DispatchQueue.main.async {
                    self?.selectionBoxView?.removeFromSuperview()
                }
                return
            }
            DispatchQueue.main.async {
                self?.replaceSelectionBox(newSelectionBoxFrame: newSelectionBoxFrame)
            }
        }).store(in: &cancellables)

        viewModel.$connectivityChanged.sink(receiveValue: { [weak self] _ in
            // This means that the document view model has changed the annotations in
            // the document, so we re-render again
            guard let self = self else {
                return
            }
            self.removeAllAnnotationsFromView()
            self.annotationViews = []
            self.initializeInitialAnnotationViews()
        }).store(in: &cancellables)
    }

    private func replaceSelectionBox(newSelectionBoxFrame: CGRect) {
        selectionBoxView?.removeFromSuperview()
        let newSelectionBoxView = UIView(frame: newSelectionBoxFrame)
        newSelectionBoxView.layer.borderWidth = 2.0
        newSelectionBoxView.layer.borderColor = UIColor.systemGray2.cgColor
        selectionBoxView = newSelectionBoxView
        pdfView.documentView?.addSubview(newSelectionBoxView)
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

        let panGestureRecognizer = UIPanGestureRecognizer(target: self, action: #selector(didPan))
        addGestureRecognizer(panGestureRecognizer)
    }

    @objc
    private func didPan(_ sender: UIPanGestureRecognizer) {
        guard let pdfInnerDocumentView = pdfView.documentView else {
            return
        }

        if sender.state == .ended {
            viewModel.addAnnotation(bounds: pdfInnerDocumentView.bounds)
            selectionBoxView?.removeFromSuperview()
        }

        let touchPoint = sender.location(in: self)
        let pointInPdf = self.convert(touchPoint, to: pdfInnerDocumentView)

        guard pdfInnerDocumentView.bounds.contains(pointInPdf) else {
            return
        }

        if sender.state == .began {
            viewModel.setSelectionBoxStartPoint(point: pointInPdf)
        }

        if sender.state != .cancelled {
            viewModel.setSelectionBoxEndPoint(point: pointInPdf)
        }
    }

    @objc
    private func didTap(_ sender: UITapGestureRecognizer) {
        viewModel.setAllAnnotationsOutOfFocus()

        guard let pdfInnerDocumentView = pdfView.documentView else {
            return
        }

        let touchPoint = sender.location(in: self)
        let pointInPdf = self.convert(touchPoint, to: pdfInnerDocumentView)

        guard pdfInnerDocumentView.bounds.contains(pointInPdf) else {
            return
        }

        viewModel.setSelectionBoxStartPoint(point: pointInPdf)
        viewModel.setSelectionBoxEndPoint(point: pointInPdf)
        viewModel.addAnnotation(bounds: pdfInnerDocumentView.bounds)
    }
}

// MARK: Adding new annotations, removing annotations
extension DocumentView {
    private func renderNewAnnotation(viewModel: AnnotationViewModel) {
        let annotationView = AnnotationView(parentView: pdfView.documentView, viewModel: viewModel)
        annotationViews.append(annotationView)
        pdfView.documentView?.addSubview(annotationView)
    }

    private func removeAllAnnotationsFromView() {
        for annotationView in annotationViews {
            annotationView.removeFromSuperview()
        }
    }
}

// MARK: Display annotations when visible pages of pdf change
extension DocumentView {
    // Note: Subviews in PdfView get shifted to the back after scrolling away
    // for a certain distance, therefore they must be brought forward
    private func showAnnotationsOfVisiblePages() {
        let annotationsToShow = annotationViews.filter({
            pdfView.visiblePagesContains(view: $0)
        })
        for annotation in annotationsToShow {
            annotation.bringToFrontOfSuperview()
        }
    }
}
