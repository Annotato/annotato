import CoreGraphics
import Foundation

class SelectionBoxViewModel: ObservableObject {
    private(set) var id: UUID
    private(set) var startPoint: CGPoint
    @Published var endPoint: CGPoint

    init(id: UUID, startPoint: CGPoint, endPoint: CGPoint?) {
        self.id = id
        self.startPoint = startPoint
        self.endPoint = endPoint ?? startPoint
    }
}

extension SelectionBoxViewModel {
    private var minX: CGFloat {
        min(startPoint.x, endPoint.x)
    }

    private var minY: CGFloat {
        min(startPoint.y, endPoint.y)
    }

    private var maxX: CGFloat {
        max(startPoint.x, endPoint.x)
    }

    private var maxY: CGFloat {
        max(startPoint.y, endPoint.y)
    }

    private var width: CGFloat {
        abs(endPoint.x - startPoint.x)
    }

    private var height: CGFloat {
        abs(endPoint.y - startPoint.y)
    }

    var frame: CGRect {
        CGRect(x: minX, y: minY, width: width, height: height)
    }

    func hasExceededBounds(bounds: CGRect) -> Bool {
        !bounds.contains(frame)
    }
}
