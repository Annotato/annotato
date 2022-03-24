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
        self.layer.borderWidth = 1.0
        self.layer.borderColor = UIColor.systemRed.cgColor
        self.backgroundColor = UIColor(white: 0.0, alpha: 0.0)
    }

    private func drawLineFromStartPointToEndPoint() {
        guard let context = UIGraphicsGetCurrentContext() else {
            return
        }
        context.setStrokeColor(UIColor.systemRed.cgColor)
        context.setLineWidth(3)
        context.beginPath()

        // TODO: The coordinates of the move function and add line function is defined differently.
        // The one from the view model is in terms of the documentview. This function is in terms of
        // some other view (probably self). I will need a view reference, or by referencing my parent directly.
        context.move(to: viewModel.selectionBoxPoint)
        context.addLine(to: viewModel.annotationPoint)
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
            print("new frame: \(newLinkLineFrame)\n----------------\n\n")
            self?.setNeedsDisplay()
        }).store(in: &cancellables)
    }

    override func draw(_ rect: CGRect) {
        drawLineFromStartPointToEndPoint()
    }
}
