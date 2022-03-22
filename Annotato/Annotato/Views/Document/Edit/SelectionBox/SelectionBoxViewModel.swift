import CoreGraphics
import Foundation

class SelectionBoxViewModel: ObservableObject {
    private(set) var id: UUID
    private var startPoint: CGPoint
    @Published var endPoint: CGPoint

    init(id: UUID, startPoint: CGPoint, endPoint: CGPoint?) {
        self.id = id
        self.startPoint = startPoint
        self.endPoint = endPoint ?? startPoint
    }
}

extension SelectionBoxViewModel {
    var minX: CGFloat {
        min(startPoint.x, endPoint.x)
    }

    var minY: CGFloat {
        min(startPoint.y, endPoint.y)
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
