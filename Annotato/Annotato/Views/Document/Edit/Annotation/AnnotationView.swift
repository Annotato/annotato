import UIKit

class AnnotationView: UIView {
    private(set) var viewModel: AnnotationViewModel

    private var palette: AnnotationPaletteView
    private var scroll: UIScrollView
    private var parts: UIStackView

    @available(*, unavailable)
    required init(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    init(viewModel: AnnotationViewModel) {
        self.viewModel = viewModel
        self.palette = AnnotationPaletteView(viewModel: viewModel.palette)
        self.scroll = UIScrollView(frame: viewModel.scrollFrame)
        self.parts = UIStackView(frame: viewModel.partsFrame)
        super.init(frame: viewModel.frame)
        initializeSubviews()
    }

    func initializeSubviews() {
        addSubview(palette)
        addSubview(scroll)
        scroll.addSubview(parts)
        setScrollViewConstraints()
        populateParts()
    }

    private func setScrollViewConstraints() {
        scroll.leftAnchor.constraint(equalTo: leftAnchor).isActive = true
        scroll.topAnchor.constraint(equalTo: palette.bottomAnchor).isActive = true
        scroll.rightAnchor.constraint(equalTo: rightAnchor).isActive = true
        scroll.bottomAnchor.constraint(equalTo: bottomAnchor).isActive = true

        parts.leadingAnchor.constraint(equalTo: scroll.leadingAnchor).isActive = true
        parts.trailingAnchor.constraint(equalTo: scroll.trailingAnchor).isActive = true
        parts.bottomAnchor.constraint(equalTo: scroll.bottomAnchor).isActive = true
        parts.topAnchor.constraint(equalTo: scroll.topAnchor).isActive = true
        parts.widthAnchor.constraint(equalTo: scroll.widthAnchor).isActive = true
    }

    func populateParts() {
        for partViewModel in viewModel.parts {
            parts.addSubview(partViewModel.toView())
        }
    }
}
