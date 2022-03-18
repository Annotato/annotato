import UIKit
import Combine

class DocumentView: UIView {
    private var documentViewModel: DocumentViewModel
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

        addTapGestureRecognizer()
        initializePdfView()
        setUpSubscriber()
        addGestureRecognizers()
        initializeAnnotationViews()
    }

    private func initializeAnnotationViews() {
        for annotation in documentViewModel.annotations {
            renderNewAnnotation(viewModel: annotation)
        }
    }

    private func initializePdfView() {
        let view = DocumentPdfView(
            frame: self.frame,
            documentPdfViewModel: documentViewModel.pdfDocument
        )
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
        documentViewModel.addAnnotation(at: touchPoint)
    }

    private func renderNewAnnotation(viewModel: AnnotationViewModel) {
        let annotation = AnnotationView(viewModel: viewModel)
        addSubview(annotation)
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
