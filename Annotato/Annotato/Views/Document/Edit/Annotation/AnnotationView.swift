import UIKit
import Combine

class AnnotationView: UIView {
    private(set) var viewModel: AnnotationViewModel

    private unowned var parentView: UIView?
    private var palette: AnnotationPaletteView
    private var mergeConflictsPalette: AnnotationMergeConflictsPaletteView
    private var scroll: UIScrollView
    private var parts: UIStackView
    private var selectionBox: SelectionBoxView
    private var linkLine: Line?
    private var cancellables: Set<AnyCancellable> = []

    @available(*, unavailable)
    required init(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    init(parentView: UIView?, viewModel: AnnotationViewModel) {
        self.viewModel = viewModel
        self.parentView = parentView
        self.palette = AnnotationPaletteView(viewModel: viewModel.palette)
        self.mergeConflictsPalette = AnnotationMergeConflictsPaletteView(viewModel: viewModel.mergeConflictPalette)
        self.scroll = UIScrollView(frame: viewModel.scrollFrame)
        self.parts = UIStackView(frame: viewModel.partsFrame)
        self.selectionBox = SelectionBoxView(viewModel: viewModel.selectionBox)
        super.init(frame: viewModel.frame)
        initializeSiblingViews()
        initializeSubviews()
        setUpSubscribers()
        addGestureRecognizers()
        self.layer.borderWidth = 1.0
        self.layer.zPosition = 2.0
        self.layer.borderColor = UIColor.systemBlue.cgColor
    }

    private func initializeSubviews() {
        addSubview(mergeConflictsPalette)
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

    private func initializeSiblingViews() {
        initializeSelectionBox()
        initializeLine()
    }

    private func initializeSelectionBox() {
        parentView?.addSubview(selectionBox)
    }

    private func initializeLine() {
        let linkLine = Line(start: viewModel.selectionBox.startPoint, end: viewModel.origin)
        self.linkLine = linkLine
        parentView?.addSubview(linkLine)
    }

    // swiftlint:disable function_body_length
    private func setUpSubscribers() {
        viewModel.$positionDidChange.sink(receiveValue: { [weak self] _ in
            guard let origin = self?.viewModel.origin else {
                return
            }

            DispatchQueue.main.async {
                self?.frame.origin = origin
                self?.linkLine?.moveEnd(to: origin)
            }
        }).store(in: &cancellables)

        viewModel.$isResizing.sink(receiveValue: { [weak self] _ in
            DispatchQueue.main.async {
                self?.resize()
            }
        }).store(in: &cancellables)

        viewModel.$addedPart.sink(receiveValue: { [weak self] addedPart in
            guard let addedPart = addedPart else {
                return
            }
            DispatchQueue.main.async {
                self?.parts.addArrangedSubview(addedPart.toView())
            }
        }).store(in: &cancellables)

        viewModel.$isRemoved.sink(receiveValue: { [weak self] isRemoved in
            if isRemoved {
                DispatchQueue.main.async {
                    self?.removeFromSuperview()
                    self?.linkLine?.removeFromSuperview()
                }
            }
        }).store(in: &cancellables)

        viewModel.$modelWasUpdated.sink { [weak self] modelWasUpdated in
            if modelWasUpdated {
                DispatchQueue.main.async {
                    self?.parts.arrangedSubviews.forEach({ $0.removeFromSuperview() })

                    self?.populateParts()

                    self?.resize()
                }
            }
        }.store(in: &cancellables)

        viewModel.$isResolving.sink { [weak self] isResolving in
            guard !isResolving else {
                return
            }
            guard let self = self else {
                return
            }
            if self.viewModel.resolveBySave {
                let mergeConflictsHeight = self.mergeConflictsPalette.height
                self.mergeConflictsPalette.resetDimensions()
                self.mergeConflictsPalette.removeFromSuperview()

                self.palette.translateUp(by: mergeConflictsHeight)

                let scrollNewOrigin = CGPoint(
                    x: self.scroll.frame.origin.x, y: self.scroll.frame.origin.y - mergeConflictsHeight)
                self.scroll.frame = CGRect(origin: scrollNewOrigin, size: self.scroll.frame.size)
            }
        }.store(in: &cancellables)
    }

    private func addGestureRecognizers() {
        isUserInteractionEnabled = true
        let panGestureRecognizer = UIPanGestureRecognizer(target: self, action: #selector(didPan))
        addGestureRecognizer(panGestureRecognizer)

        let tapGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(didTap))
        addGestureRecognizer(tapGestureRecognizer)
    }

    @objc
    private func didTap(_ sender: UITapGestureRecognizer) {
        viewModel.inFocus()
    }

    @objc
    private func didPan(_ sender: UIPanGestureRecognizer) {
        guard let superview = superview else {
            return
        }
        let previousCenter = viewModel.center
        superview.bringSubviewToFront(self)
        let translation = sender.translation(in: superview)
        viewModel.translateCenter(by: translation)
        sender.setTranslation(.zero, in: superview)

        if viewModel.hasExceededBounds(bounds: superview.bounds) {
            viewModel.center = previousCenter
        }
    }

    private func resize() {
        parts.frame = viewModel.partsFrame
        self.frame = viewModel.frame
    }
}
