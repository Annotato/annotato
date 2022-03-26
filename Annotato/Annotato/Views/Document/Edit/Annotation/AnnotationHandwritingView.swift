import UIKit
import PencilKit
import Combine

class AnnotationHandwritingView: PKCanvasView, AnnotationPartView {
    private var viewModel: AnnotationHandwritingViewModel
    private var cancellables: Set<AnyCancellable> = []
    private var customDelegate: AnnotationHandwritingViewDelegate

    @available(*, unavailable)
    required init(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    init(viewModel: AnnotationHandwritingViewModel) {
        self.viewModel = viewModel
        self.customDelegate = AnnotationHandwritingViewDelegate(viewModel: viewModel)
        super.init(frame: viewModel.frame)
        self.delegate = customDelegate
        self.drawing = viewModel.handwritingDrawing
        setUpSubscribers()
        addGestureRecognizers()
        self.addAnnotationPartBorders()
    }

    private func setUpSubscribers() {
        viewModel.$isEditing.sink(receiveValue: { [weak self] isEditing in
            self?.drawingGestureRecognizer.isEnabled = isEditing
        }).store(in: &cancellables)

        viewModel.$isRemoved.sink(receiveValue: { [weak self] isRemoved in
            if isRemoved {
                self?.removeFromSuperview()
            }
        }).store(in: &cancellables)

        viewModel.$isSelected.sink(receiveValue: { [weak self] isSelected in
            self?.drawingGestureRecognizer.isEnabled = isSelected
            if isSelected {
                self?.showSelected()
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
    private var viewModel: AnnotationHandwritingViewModel

    init(viewModel: AnnotationHandwritingViewModel) {
        self.viewModel = viewModel
    }

    func canvasViewDrawingDidChange(_ canvasView: PKCanvasView) {
        viewModel.setHandwritingDrawing(to: canvasView.drawing)
    }
}
