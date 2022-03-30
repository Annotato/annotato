import Combine
import UIKit

 class LinkLineView: UIView {
    private var pointA: CGPoint
    private var pointB: CGPoint

     // Appearance configuration
     var strokeColor: CGColor = UIColor.systemGray.cgColor
     var lineWidth: CGFloat = 3

    @available(*, unavailable)
    required init(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

     init(pointA: CGPoint, pointB: CGPoint) {
         self.pointA = pointA
         self.pointB = pointB
        super.init(frame: CGRect(startPoint: pointA, endPoint: pointB))
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

        let reframedPointA = superview.convert(pointA, to: self)
        let reframedPointB = superview.convert(pointB, to: self)
        context.move(to: reframedPointA)
        context.addLine(to: reframedPointB)
        context.strokePath()
    }

     func movePointA(to newPoint: CGPoint) {
         pointA = newPoint
         reframe()
         setNeedsDisplay()
     }

     func movePointB(to newPoint: CGPoint) {
         pointB = newPoint
         reframe()
         setNeedsDisplay()
     }

     private func reframe() {
         frame = newFrame
     }

     private var newFrame: CGRect {
         CGRect(startPoint: pointA, endPoint: pointB)
     }
 }
