import UIKit

class DocumentView: UIView {
    private var documentViewModel: DocumentViewModel

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
            let view = DocumentAnnotationView(annotationViewModel: annotation)
            addSubview(view)
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
        let annotation = DocumentAnnotationView(
            annotationViewModel: DocumentAnnotationViewModel(center: touchPoint, width: newAnnotationWidth, parts: []))
        addSubview(annotation)
    }
}
