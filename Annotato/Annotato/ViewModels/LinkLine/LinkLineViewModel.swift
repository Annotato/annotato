import CoreGraphics
import Combine
import Foundation

class LinkLineViewModel: ObservableObject {
    private(set) var id: UUID
    private var cancellables: Set<AnyCancellable> = []

    @Published var selectionBoxPoint: CGPoint
    @Published var annotationPoint: CGPoint

    /*
     Can potentially change to unowned when we have implemented that
     the deletion of an annotation
     will ensure selection box and this link line will be deallocated too
     I.e. we only change to unowned when all three have the same lifetime
     Otherwise, unowned will give runtime error here.
     */
    // TODO: Check on whether can change to unowned
    weak var annotationViewModel: AnnotationViewModel?
    weak var selectionBoxViewModel: SelectionBoxViewModel?

    init(id: UUID, selectionBoxViewModel: SelectionBoxViewModel, annotationViewModel: AnnotationViewModel) {
        self.id = id
        self.selectionBoxViewModel = selectionBoxViewModel
        self.annotationViewModel = annotationViewModel

        self.selectionBoxPoint = selectionBoxViewModel.endPoint
        self.annotationPoint = annotationViewModel.origin
        setUpSubscribers()
    }

    private func setUpSubscribers() {
        annotationViewModel?.$positionDidChange.sink(receiveValue: { [weak self] _ in
            guard let annotationViewModel = self?.annotationViewModel else {
                return
            }
            self?.annotationPoint = annotationViewModel.origin
        }).store(in: &cancellables)

        selectionBoxViewModel?.$endPoint.sink(receiveValue: { [weak self] newEndPoint in
            self?.selectionBoxPoint = newEndPoint
        }).store(in: &cancellables)
    }
}

extension LinkLineViewModel {
    private var minX: CGFloat {
        min(selectionBoxPoint.x, annotationPoint.x)
    }

    private var minY: CGFloat {
        min(selectionBoxPoint.y, annotationPoint.y)
    }

    private var maxX: CGFloat {
        max(selectionBoxPoint.x, annotationPoint.x)
    }

    private var maxY: CGFloat {
        max(selectionBoxPoint.y, annotationPoint.y)
    }

    private var width: CGFloat {
        abs(annotationPoint.x - selectionBoxPoint.x)
    }

    private var height: CGFloat {
        abs(annotationPoint.y - selectionBoxPoint.y)
    }

    var frame: CGRect {
        CGRect(x: minX, y: minY, width: width, height: height)
    }
}
