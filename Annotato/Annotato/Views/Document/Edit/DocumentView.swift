import UIKit

class DocumentView: UIView {
    private var documentViewModel: DocumentViewModel
    private var annotations: [DocumentAnnotationView] = []

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
        initializeAnnotationViews()
    }

    private func initializeAnnotationViews() {
        for annotation in documentViewModel.annotations {
            addNewAnnotation(annotationViewModel: annotation)
        }
    }

    private func addTapGestureRecognizer() {
        isUserInteractionEnabled = true
        let gestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(didTap))
        addGestureRecognizer(gestureRecognizer)
    }

    @objc
    private func didTap(_ sender: UITapGestureRecognizer) {
        let touchPoint = sender.location(in: self)
        let newAnnotationWidth = 200.0
        addNewAnnotation(
            annotationViewModel: DocumentAnnotationViewModel(center: touchPoint, width: newAnnotationWidth, parts: [])
        )
    }

    private func addNewAnnotation(annotationViewModel: DocumentAnnotationViewModel) {
        let annotation = DocumentAnnotationView(annotationViewModel: annotationViewModel)
        annotation.delegate = self
        annotations.append(annotation)
        addSubview(annotation)
    }

    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        super.touchesBegan(touches, with: event)

        let touch = touches.first
        guard let location = touch?.location(in: self) else {
            return
        }

        for annotation in annotations where !annotation.frame.contains(location) {
            annotation.didResignFocus()
        }
    }
}

extension DocumentView: DocumentAnnotationDelegate {
    func didSelect(selected: DocumentAnnotationView) {
        for annotation in annotations where annotation != selected {
            annotation.didResignFocus()
        }
    }
}
