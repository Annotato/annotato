import Combine
import UIKit

class Line: UIView {
    private var start: CGPoint
    private var end: CGPoint

    // Appearance configuration
    var strokeColor: CGColor = UIColor.systemGray.cgColor
    var lineWidth: CGFloat = 2

    @available(*, unavailable)
    required init(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    init(start: CGPoint, end: CGPoint) {
        self.start = start
        self.end = end
        super.init(frame: CGRect(startPoint: start, endPoint: end))
        self.layer.zPosition = 1.0
        isOpaque = false
    }

    override func draw(_ rect: CGRect) {
        guard let context = UIGraphicsGetCurrentContext() else {
            return
        }

        context.setStrokeColor(strokeColor)
        context.setLineWidth(lineWidth)
        context.beginPath()

        guard let superview = superview else {
            return
        }

        let reframedPointA = superview.convert(start, to: self)
        let reframedPointB = superview.convert(end, to: self)
        context.move(to: reframedPointA)
        context.addLine(to: reframedPointB)
        context.strokePath()
    }

    func movePointA(to newPoint: CGPoint) {
        start = newPoint
        reframe()
        setNeedsDisplay()
    }

    func movePointB(to newPoint: CGPoint) {
        end = newPoint
        reframe()
        setNeedsDisplay()
    }

    private func reframe() {
        frame = newFrame
    }

    private var newFrame: CGRect {
        CGRect(startPoint: start, endPoint: end)
    }
}
