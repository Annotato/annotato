import CoreGraphics
import Foundation
import AnnotatoSharedLibrary
import Combine

class SelectionBoxViewModel: ObservableObject {
    private(set) var model: SelectionBox
    private var cancellables: Set<AnyCancellable> = []

    @Published private(set) var isRemoved = false

    init(model: SelectionBox) {
        self.model = model
    }

    var startPoint: CGPoint {
        model.startPoint
    }

    var endPoint: CGPoint {
        model.endPoint
    }

    func didDelete() {
        self.isRemoved = true
    }

    func receiveDelete() {
        self.isRemoved = true
    }
}

extension SelectionBoxViewModel {
    var frame: CGRect {
        CGRect(startPoint: startPoint, endPoint: endPoint)
    }

    func hasExceededBounds(bounds: CGRect) -> Bool {
        !bounds.contains(frame)
    }
}
