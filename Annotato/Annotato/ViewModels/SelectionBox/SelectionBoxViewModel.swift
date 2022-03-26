import CoreGraphics
import Foundation
import AnnotatoSharedLibrary
import Combine

class SelectionBoxViewModel: ObservableObject {
    private(set) var model: SelectionBox
    private var cancellables: Set<AnyCancellable> = []

    @Published private(set) var endPointDidChange = false
    @Published private(set) var isRemoved = false

    init(model: SelectionBox) {
        self.model = model
        setUpSubscribers()
    }

    private func setUpSubscribers() {
        model.$endPoint.sink(receiveValue: { [weak self] _ in
            self?.endPointDidChange = true
        }).store(in: &cancellables)
    }

    var endPoint: CGPoint {
        model.endPoint
    }

    var startPoint: CGPoint {
        model.startPoint
    }

    func didDelete() {
        self.isRemoved = true
    }
}

// MARK: Updating the end point
extension SelectionBoxViewModel {
    func updateEndPoint(newEndPoint: CGPoint) {
        model.setEndPoint(to: newEndPoint)
    }
}

extension SelectionBoxViewModel {
    private var minX: CGFloat {
        min(model.startPoint.x, model.endPoint.x)
    }

    private var minY: CGFloat {
        min(model.startPoint.y, model.endPoint.y)
    }

    private var maxX: CGFloat {
        max(model.startPoint.x, model.endPoint.x)
    }

    private var maxY: CGFloat {
        max(model.startPoint.y, model.endPoint.y)
    }

    private var width: CGFloat {
        abs(model.endPoint.x - model.startPoint.x)
    }

    private var height: CGFloat {
        abs(model.endPoint.y - model.startPoint.y)
    }

    var frame: CGRect {
        CGRect(x: minX, y: minY, width: width, height: height)
    }

    func hasExceededBounds(bounds: CGRect) -> Bool {
        !bounds.contains(frame)
    }
}
