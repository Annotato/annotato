import UIKit
import PDFKit
import Combine
import AnnotatoSharedLibrary

class DocumentView: UIView {
    private var presenter: DocumentPresenter
    private var cancellables: Set<AnyCancellable> = []

    private var pdfView: DocumentPdfView?
    private var annotationViews: [AnnotationView]
    private var selectionBoxView: UIView?

    @available(*, unavailable)
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    init(frame: CGRect, documentPresenter: DocumentPresenter) {
        self.presenter = documentPresenter
        self.annotationViews = []

        if let pdfDocument = documentPresenter.pdfDocument {
            self.pdfView = DocumentPdfView(
                frame: .zero,
                pdfPresenter: pdfDocument
            )
        }

        super.init(frame: frame)

        addGestureRecognizers()
        addObservers()
        initializePdfView()
        setUpSubscribers()
        initializeInitialAnnotationViews()
    }

    private func initializeInitialAnnotationViews() {
        for annotation in presenter.annotations {
            renderNewAnnotation(presenter: annotation)
        }
    }

    private func initializePdfView() {
        guard let pdfView = pdfView else {
            return
        }

        addSubview(pdfView)
        pdfView.translatesAutoresizingMaskIntoConstraints = false
        pdfView.topAnchor.constraint(equalTo: topAnchor).isActive = true
        pdfView.bottomAnchor.constraint(equalTo: bottomAnchor).isActive = true
        pdfView.leftAnchor.constraint(equalTo: leftAnchor).isActive = true
        pdfView.rightAnchor.constraint(equalTo: rightAnchor).isActive = true
    }

    private func setUpSubscribers() {
        presenter.$addedAnnotation.sink(receiveValue: { [weak self] addedAnnotation in
            guard let addedAnnotation = addedAnnotation else {
                return
            }

            DispatchQueue.main.async {
                self?.renderNewAnnotation(presenter: addedAnnotation)
            }
        }).store(in: &cancellables)

        presenter.$selectionBoxFrame.sink(receiveValue: { [weak self] newSelectionBoxFrame in
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
    }

    private func replaceSelectionBox(newSelectionBoxFrame: CGRect) {
        selectionBoxView?.removeFromSuperview()
        let newSelectionBoxView = UIView(frame: newSelectionBoxFrame)
        newSelectionBoxView.layer.borderWidth = 2.0
        newSelectionBoxView.layer.borderColor = UIColor.systemGray2.cgColor
        selectionBoxView = newSelectionBoxView
        pdfView?.documentView?.addSubview(newSelectionBoxView)
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
        guard let pdfInnerDocumentView = pdfView?.documentView else {
            return
        }

        if sender.state == .ended {
            presenter.addAnnotation(bounds: pdfInnerDocumentView.bounds)
            selectionBoxView?.removeFromSuperview()
        }

        let touchPoint = sender.location(in: self)
        let pointInPdf = self.convert(touchPoint, to: pdfInnerDocumentView)

        guard pdfInnerDocumentView.bounds.contains(pointInPdf) else {
            return
        }

        if sender.state == .began {
            presenter.setSelectionBoxStartPoint(point: pointInPdf)
        }

        if sender.state != .cancelled {
            presenter.setSelectionBoxEndPoint(point: pointInPdf)
        }
    }

    @objc
    private func didTap(_ sender: UITapGestureRecognizer) {
        presenter.setAllAnnotationsOutOfFocus()

        guard let pdfInnerDocumentView = pdfView?.documentView else {
            return
        }

        let touchPoint = sender.location(in: self)
        let pointInPdf = self.convert(touchPoint, to: pdfInnerDocumentView)

        guard pdfInnerDocumentView.bounds.contains(pointInPdf) else {
            return
        }

        presenter.setSelectionBoxStartPoint(point: pointInPdf)
        presenter.setSelectionBoxEndPoint(point: pointInPdf)
        presenter.addAnnotation(bounds: pdfInnerDocumentView.bounds)
    }
}

// MARK: Adding new annotations, removing annotations
extension DocumentView {
    private func renderNewAnnotation(presenter: AnnotationPresenter) {
        let annotationView = AnnotationView(parentView: pdfView?.documentView, presenter: presenter)
        annotationViews.append(annotationView)
        pdfView?.documentView?.addSubview(annotationView)
    }
}

// MARK: Display annotations when visible pages of pdf change
extension DocumentView {
    // Note: Subviews in PdfView get shifted to the back after scrolling away
    // for a certain distance, therefore they must be brought forward
    private func showAnnotationsOfVisiblePages() {
        guard let pdfView = pdfView else {
            return
        }

        let annotationsToShow = annotationViews.filter({
            pdfView.visiblePagesContains(view: $0)
        })
        for annotation in annotationsToShow {
            annotation.bringToFrontOfSuperview()
        }
    }
}
