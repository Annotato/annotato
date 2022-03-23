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

    func hasExceededBounds(bounds: CGRect) -> Bool {
        let hasExceededTop = minY < bounds.minY
        let hasExceededBottom = maxY > bounds.maxY
        let hasExceededLeft = minX < bounds.minX
        let hasExceededRight = maxX > bounds.maxX
        if hasExceededTop || hasExceededBottom || hasExceededLeft || hasExceededRight {
            return true
        }
        return false
    }
}

extension SelectionBoxViewModel {
    var minX: CGFloat {
        min(startPoint.x, endPoint.x)
    }

    var minY: CGFloat {
        min(startPoint.y, endPoint.y)
    }

    var maxX: CGFloat {
        max(startPoint.x, endPoint.x)
    }

    var maxY: CGFloat {
        max(startPoint.y, endPoint.y)
    }

    var width: CGFloat {
        abs(endPoint.x - startPoint.x)
    }

    var height: CGFloat {
        abs(endPoint.y - startPoint.y)
    }

    var frame: CGRect {
        CGRect(x: minX, y: minY, width: width, height: height)
    }
}
