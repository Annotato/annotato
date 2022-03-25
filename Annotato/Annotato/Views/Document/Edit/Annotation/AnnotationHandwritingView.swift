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
    }

    private func setUpSubscribers() {
        viewModel.$isEditing.sink(receiveValue: { [weak self] isEditing in
            self?.isUserInteractionEnabled = isEditing
        }).store(in: &cancellables)

        viewModel.$isRemoved.sink(receiveValue: { [weak self] isRemoved in
            if isRemoved {
                self?.removeFromSuperview()
            }
        }).store(in: &cancellables)

        viewModel.$isSelected.sink(receiveValue: { [weak self] isSelected in
            self?.isUserInteractionEnabled = isSelected
            if isSelected {
                self?.showSelected()
            }
        }).store(in: &cancellables)
    }
}

class AnnotationHandwritingViewDelegate: NSObject, PKCanvasViewDelegate {
    private var viewModel: AnnotationHandwritingViewModel

    init(viewModel: AnnotationHandwritingViewModel) {
        self.viewModel = viewModel
    }

    func canvasViewDrawingDidChange(_ canvasView: PKCanvasView) {
        viewModel.setHandwriting(to: canvasView.drawing.dataRepresentation())
    }
}
