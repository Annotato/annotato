import CoreGraphics

extension CGRect {
    init(startPoint: CGPoint, endPoint: CGPoint) {
        let minX = min(startPoint.x, endPoint.x)
        let minY = min(startPoint.y, endPoint.y)
        let width = abs(startPoint.x - endPoint.x)
        let height = abs(startPoint.y - endPoint.y)

        self.init(x: minX, y: minY, width: width, height: height)
    }

    var center: CGPoint {
        CGPoint(x: midX, y: midY)
    }
}
