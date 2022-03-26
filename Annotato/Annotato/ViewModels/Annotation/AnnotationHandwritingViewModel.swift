import Foundation
import CoreGraphics
import Combine
import AnnotatoSharedLibrary
import PencilKit

class AnnotationHandwritingViewModel: AnnotationPartViewModel {
    var handwritingModel: AnnotationHandwriting

    var handwriting: Data {
        handwritingModel.handwriting
    }
    var handwritingDrawing: PKDrawing {
        (try? PKDrawing(data: handwriting)) ?? PKDrawing()
    }

    init(model: AnnotationHandwriting, width: Double, origin: CGPoint = .zero) {
        self.handwritingModel = model
        super.init(model: model, width: width, origin: origin)

        setUpSubscribers()
    }

    private func setUpSubscribers() {
        handwritingModel.$isRemoved.sink(receiveValue: { [weak self] isRemoved in
            self?.isRemoved = isRemoved
        }).store(in: &cancellables)
    }

    func setHandwritingDrawing(to newHandwritingDrawing: PKDrawing) {
        handwritingModel.setHandwriting(to: newHandwritingDrawing.dataRepresentation())
    }

    override func toView() -> AnnotationPartView {
        AnnotationHandwritingView(viewModel: self)
    }
}
