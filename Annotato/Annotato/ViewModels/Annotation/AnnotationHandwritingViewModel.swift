import Foundation
import CoreGraphics
import Combine
import AnnotatoSharedLibrary
import PencilKit

class AnnotationHandwritingViewModel: AnnotationPartViewModel, ObservableObject {
    weak var parentViewModel: AnnotationViewModel?

    private(set) var model: AnnotationPart
    private(set) var origin: CGPoint
    private(set) var width: Double
    private var cancellables: Set<AnyCancellable> = []

    var handwritingModel: AnnotationHandwriting? {
        model as? AnnotationHandwriting
    }
    var id: UUID {
        model.id
    }
    var height: Double {
        model.height
    }
    var handwriting: Data {
        handwritingModel?.handwriting ?? Data()
    }
    var handwritingDrawing: PKDrawing {
        (try? PKDrawing(data: handwriting)) ?? PKDrawing()
    }

    @Published private(set) var isEditing = false
    @Published private(set) var isRemoved = false
    @Published var isSelected = false

    init(model: AnnotationHandwriting, width: Double, origin: CGPoint = .zero) {
        self.model = model
        self.width = width
        self.origin = origin

        setUpSubscribers()
    }

    func toView() -> AnnotationPartView {
        AnnotationHandwritingView(viewModel: self)
    }

    func enterEditMode() {
        isEditing = true
    }

    func enterViewMode() {
        isEditing = false
    }

    func setHandwriting(to newHandwriting: Data) {
        handwritingModel?.setHandwriting(to: newHandwriting)
    }

    private func setUpSubscribers() {
        handwritingModel?.$isRemoved.sink(receiveValue: { [weak self] isRemoved in
            self?.isRemoved = isRemoved
        }).store(in: &cancellables)
    }
}

extension AnnotationHandwritingViewModel {
    var editFrame: CGRect {
        CGRect(x: .zero, y: .zero, width: width, height: model.height)
    }
}
