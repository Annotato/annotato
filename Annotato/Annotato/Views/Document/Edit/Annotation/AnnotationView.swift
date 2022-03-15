import UIKit

class AnnotationView: UIView {
    private(set) var viewModel: AnnotationViewModel

    @available(*, unavailable)
    required init(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    init(viewModel: AnnotationViewModel) {
        self.viewModel = viewModel
        super.init(frame: viewModel.frame)
        initializeSubviews()
    }

    func initializeSubviews() {
        let palette = AnnotationPaletteView(viewModel: viewModel.palette)
        addSubview(palette)
    }
}
