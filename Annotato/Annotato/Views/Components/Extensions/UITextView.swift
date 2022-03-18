import UIKit

extension UITextView {
    func resizeFrameToFitContent() {
        let fixedWidth = frame.size.width
        let newSize = sizeThatFits(
            CGSize(width: fixedWidth, height: CGFloat.greatestFiniteMagnitude)
        )
        frame.size = CGSize(width: max(newSize.width, fixedWidth), height: newSize.height)
    }
}
