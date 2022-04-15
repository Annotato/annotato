import UIKit
import Combine

class AnnotationTextView: UITextView, AnnotationPartView {
    private(set) var presenter: AnnotationTextPresenter
    private var cancellables: Set<AnyCancellable> = []

    @available(*, unavailable)
    required init(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    init(presenter: AnnotationTextPresenter) {
        self.presenter = presenter
        super.init(frame: presenter.frame, textContainer: nil)
        self.text = presenter.content
        self.isEditable = presenter.isEditing
        self.isScrollEnabled = false
        self.delegate = self
        setUpSubscribers()
        addGestureRecognizers()
        self.addAnnotationPartBorders()
    }

    private func setUpSubscribers() {
        presenter.$isEditing.sink(receiveValue: { [weak self] isEditing in
            DispatchQueue.main.async {
                self?.isEditable = isEditing
            }
        }).store(in: &cancellables)

        presenter.$isRemoved.sink(receiveValue: { [weak self] isRemoved in
            if isRemoved {
                DispatchQueue.main.async {
                    self?.removeFromSuperview()
                }
            }
        }).store(in: &cancellables)

        presenter.$isSelected.sink(receiveValue: { [weak self] isSelected in
            if isSelected {
                DispatchQueue.main.async {
                    self?.becomeFirstResponder()
                    self?.showSelected()
                }
            } else {
                DispatchQueue.main.async {
                    self?.resignFirstResponder()
                }
            }
        }).store(in: &cancellables)
    }
}

extension AnnotationTextView: UITextViewDelegate {
    func textViewDidChange(_ textView: UITextView) {
        guard let text = self.text else {
            return
        }

        resizeFrameToFitContent()
        presenter.setContent(to: text)
        presenter.setHeight(to: frame.height)
    }
}

// MARK: Gestures
extension AnnotationTextView {
    private func addGestureRecognizers() {
        let tapGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(didTap))
        tapGestureRecognizer.delegate = self
        addGestureRecognizer(tapGestureRecognizer)
    }

    @objc
    private func didTap() {
        if isEditable {
            presenter.didSelect()
        }
    }
}

extension AnnotationTextView: UIGestureRecognizerDelegate {
    func gestureRecognizer(
        _ gestureRecognizer: UIGestureRecognizer,
        shouldRecognizeSimultaneouslyWith otherGestureRecognizer: UIGestureRecognizer
    ) -> Bool {
        true
    }
}
