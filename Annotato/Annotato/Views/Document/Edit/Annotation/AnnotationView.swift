import UIKit
import Combine

class AnnotationView: UIView {
    private(set) var viewModel: AnnotationViewModel

    private var palette: AnnotationPaletteView
    private var scroll: UIScrollView
    private var parts: UIStackView
    private var cancellables: Set<AnyCancellable> = []

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
        setUpSubscribers()
        addPanGestureRecognizer()
        self.layer.borderWidth = 1.0
        self.layer.borderColor = UIColor.systemBlue.cgColor
    }

    private func initializeSubviews() {
        addSubview(palette)
        setUpScrollAndParts()
        populateParts()
    }

    private func setUpScrollAndParts() {
        addSubview(scroll)
        scroll.translatesAutoresizingMaskIntoConstraints = false
        scroll.leftAnchor.constraint(equalTo: leftAnchor).isActive = true
        scroll.topAnchor.constraint(equalTo: palette.bottomAnchor).isActive = true
        scroll.rightAnchor.constraint(equalTo: rightAnchor).isActive = true
        scroll.bottomAnchor.constraint(equalTo: bottomAnchor).isActive = true

        parts.axis = .vertical
        scroll.addSubview(parts)
        parts.leadingAnchor.constraint(equalTo: scroll.leadingAnchor).isActive = true
        parts.trailingAnchor.constraint(equalTo: scroll.trailingAnchor).isActive = true
        parts.bottomAnchor.constraint(equalTo: scroll.bottomAnchor).isActive = true
        parts.topAnchor.constraint(equalTo: scroll.topAnchor).isActive = true
        parts.widthAnchor.constraint(equalTo: scroll.widthAnchor).isActive = true
    }

    private func populateParts() {
        for partViewModel in viewModel.parts {
            parts.addArrangedSubview(partViewModel.toView())
        }
    }

    private func setUpSubscribers() {
        viewModel.$origin.sink(receiveValue: { [weak self] origin in
            self?.frame.origin = origin
        }).store(in: &cancellables)

        viewModel.$isResizing.sink(receiveValue: { [weak self] _ in
            self?.resize()
        }).store(in: &cancellables)

        viewModel.$partToAppend.sink(receiveValue: { [weak self] partViewModel in
            guard let partViewModel = partViewModel else {
                return
            }
            self?.parts.addArrangedSubview(partViewModel.toView())
        }).store(in: &cancellables)

        viewModel.$isRemoved.sink(receiveValue: { [weak self] isRemoved in
            if isRemoved {
                self?.removeFromSuperview()
            }
        }).store(in: &cancellables)
    }

    private func addPanGestureRecognizer() {
        isUserInteractionEnabled = true
        let gestureRecognizer = UIPanGestureRecognizer(target: self, action: #selector(didPan))
        addGestureRecognizer(gestureRecognizer)
    }

    @objc
    private func didPan(_ sender: UIPanGestureRecognizer) {
        guard let superview = superview else {
            return
        }
        print("point in inner documentview: \(sender.location(in: superview))")
        print("point in scrollview: \(sender.location(in: superview.superview))")
        print("point in pdfview: \(sender.location(in: superview.superview?.superview))")

        print("bounds of inner documentview: \(superview.bounds)")
        print("bounds of scrollview: \(superview.superview?.bounds)")
        print("bounds of pdfview: \(superview.superview?.superview?.bounds)")

        let previousCenter = viewModel.center
        superview.bringSubviewToFront(self)
        let translation = sender.translation(in: superview)
        viewModel.translateCenter(by: translation)
        sender.setTranslation(.zero, in: superview)

        if hasExceededBounds(bounds: superview.bounds) {
            viewModel.center = previousCenter
        }
        print("-----------------------------\n\n")
    }

    private func resize() {
        parts.frame = viewModel.partsFrame
        self.frame = viewModel.frame
    }
}
