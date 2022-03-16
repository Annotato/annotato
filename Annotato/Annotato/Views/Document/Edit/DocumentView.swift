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

        setUpSubscriber()
        addGestureRecognizers()
        initializeAnnotationViews()
    }

    private func initializeAnnotationViews() {
        for annotation in documentViewModel.annotations {
            renderNewAnnotation(viewModel: annotation)
        }
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

//    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
//        super.touchesBegan(touches, with: event)
//
//        let touch = touches.first
//        guard let location = touch?.location(in: self) else {
//            return
//        }
//
//        for annotation in annotations where !annotation.frame.contains(location) {
//            annotation.didResignFocus()
//        }
//    }
}

// extension DocumentView: DocumentAnnotationDelegate {
//    func didSelect(selected: DocumentAnnotationView) {
//        for annotation in annotations where annotation != selected {
//            annotation.didResignFocus()
//        }
//    }
// }
