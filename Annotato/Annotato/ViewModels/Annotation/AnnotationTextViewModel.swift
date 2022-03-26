import Foundation
import CoreGraphics
import Combine
import AnnotatoSharedLibrary

class AnnotationTextViewModel: AnnotationPartViewModel {
    private var textModel: AnnotationText

    var content: String {
        textModel.content
    }

    init(model: AnnotationText, width: Double, origin: CGPoint = .zero) {
        self.textModel = model
        super.init(model: model, width: width, origin: origin)

        setUpSubscribers()
    }

    private func setUpSubscribers() {
        textModel.$isRemoved.sink(receiveValue: { [weak self] isRemoved in
            self?.isRemoved = isRemoved
        }).store(in: &cancellables)
    }

    func setContent(to newContent: String) {
        textModel.setContent(to: newContent)
    }

    override func toView() -> AnnotationPartView {
        AnnotationTextView(viewModel: self)
    }
}
