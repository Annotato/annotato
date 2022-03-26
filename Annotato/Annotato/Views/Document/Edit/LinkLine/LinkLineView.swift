import Combine
import UIKit

class LinkLineView: UIView {
    private(set) var viewModel: LinkLineViewModel
    private var cancellables: Set<AnyCancellable> = []

    @available(*, unavailable)
    required init(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    init(viewModel: LinkLineViewModel) {
        self.viewModel = viewModel
        super.init(frame: viewModel.frame)
        setUpSubscribers()
        isOpaque = false
    }

    private func drawLineFromSelectionBoxToAnnotation() {
        guard let context = UIGraphicsGetCurrentContext() else {
            return
        }
        context.setStrokeColor(UIColor.systemRed.cgColor)
        context.setLineWidth(1)
        context.beginPath()
        guard let superview = superview else {
            return
        }
        let selectionBoxPoint = superview.convert(viewModel.selectionBoxPoint, to: self)
        let annotationPoint = superview.convert(viewModel.annotationPoint, to: self)
        context.move(to: selectionBoxPoint)
        context.addLine(to: annotationPoint)
        context.strokePath()
    }

    private func setUpSubscribers() {
        viewModel.$selectionBoxPoint.sink(receiveValue: { [weak self] _ in
            guard let newLinkLineFrame = self?.viewModel.frame else {
                return
            }
            self?.frame = newLinkLineFrame
            self?.setNeedsDisplay()
        }).store(in: &cancellables)

        viewModel.$annotationPoint.sink(receiveValue: { [weak self] _ in
            guard let newLinkLineFrame = self?.viewModel.frame else {
                return
            }
            self?.frame = newLinkLineFrame
            self?.setNeedsDisplay()
        }).store(in: &cancellables)
    }

    override func draw(_ rect: CGRect) {
        drawLineFromSelectionBoxToAnnotation()
    }
}
