import UIKit
import PencilKit
import Combine

class AnnotationHandwritingView: PKCanvasView, AnnotationPartView {
    private var viewModel: AnnotationHandwritingPresenter
    private var cancellables: Set<AnyCancellable> = []
    // swiftlint:disable:next weak_delegate
    private var customDelegate: AnnotationHandwritingViewDelegate
    private var toolPicker = PKToolPicker()

    @available(*, unavailable)
    required init(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    init(presenter: AnnotationHandwritingPresenter) {
        self.viewModel = presenter
        self.customDelegate = AnnotationHandwritingViewDelegate(viewModel: presenter)
        super.init(frame: presenter.frame)
        self.delegate = customDelegate
        self.drawing = presenter.handwritingDrawing
        initializeSubviews()
        setUpSubscribers()
        addGestureRecognizers()
        self.addAnnotationPartBorders()
    }

    private func initializeSubviews() {
        initializeToolPicker()
    }

    private func initializeToolPicker() {
        toolPicker.addObserver(self)
        toolPicker.setVisible(true, forFirstResponder: self)
    }

    private func setUpSubscribers() {
        viewModel.$isEditing.sink(receiveValue: { [weak self] isEditing in
            DispatchQueue.main.async {
                self?.drawingGestureRecognizer.isEnabled = isEditing
            }
        }).store(in: &cancellables)

        viewModel.$isRemoved.sink(receiveValue: { [weak self] isRemoved in
            if isRemoved {
                DispatchQueue.main.async {
                    self?.removeFromSuperview()
                }
            }
        }).store(in: &cancellables)

        viewModel.$isSelected.sink(receiveValue: { [weak self] isSelected in
            DispatchQueue.main.async {
                self?.drawingGestureRecognizer.isEnabled = isSelected
            }
            if isSelected {
                DispatchQueue.main.async {
                    self?.becomeFirstResponder()
                    self?.showSelected()
                }
            }
        }).store(in: &cancellables)
    }
}

// MARK: Gestures
extension AnnotationHandwritingView {
    private func addGestureRecognizers() {
        let tapGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(didTap))
        addGestureRecognizer(tapGestureRecognizer)
    }

    @objc
    private func didTap() {
        viewModel.didSelect()
    }
}

class AnnotationHandwritingViewDelegate: NSObject, PKCanvasViewDelegate {
    private var viewModel: AnnotationHandwritingPresenter

    init(viewModel: AnnotationHandwritingPresenter) {
        self.viewModel = viewModel
    }

    func canvasViewDrawingDidChange(_ canvasView: PKCanvasView) {
        viewModel.setHandwritingDrawing(to: canvasView.drawing)
    }
}
