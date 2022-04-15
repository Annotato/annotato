import UIKit
import Combine

class AnnotationView: UIView {
    private(set) var presenter: AnnotationPresenter

    private unowned var parentView: UIView?
    private var palette: AnnotationPaletteView
    private var mergeConflictsPalette: AnnotationMergeConflictsPaletteView?
    private var scroll: UIScrollView
    private var parts: UIStackView
    private var selectionBox: SelectionBoxView
    private var linkLine: Line?
    private var cancellables: Set<AnyCancellable> = []

    @available(*, unavailable)
    required init(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    init(parentView: UIView?, presenter: AnnotationPresenter) {
        self.presenter = presenter
        self.parentView = parentView
        self.palette = AnnotationPaletteView(presenter: presenter.palette)

        if let mergeConflictPaletteViewModel = presenter.mergeConflictPalette {
            self.mergeConflictsPalette = AnnotationMergeConflictsPaletteView(presenter: mergeConflictPaletteViewModel)
        }

        self.scroll = UIScrollView(frame: presenter.scrollFrame)
        self.parts = UIStackView(frame: presenter.partsFrame)
        self.selectionBox = SelectionBoxView(presenter: presenter.selectionBox)

        super.init(frame: presenter.frame)
        initializeSiblingViews()
        initializeSubviews()
        setUpSubscribers()
        addGestureRecognizers()
        self.layer.borderWidth = 1.0
        self.layer.zPosition = 2.0
        self.layer.borderColor = UIColor.systemBlue.cgColor
    }

    private func initializeSubviews() {
        if let mergeConflictsPalette = mergeConflictsPalette {
            addSubview(mergeConflictsPalette)
        }
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
        for partViewModel in presenter.parts {
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
        let linkLine = Line(start: presenter.selectionBox.startPoint, end: presenter.origin)
        self.linkLine = linkLine
        parentView?.addSubview(linkLine)
    }

    // swiftlint:disable function_body_length
    private func setUpSubscribers() {
        presenter.$positionDidChange.sink(receiveValue: { [weak self] _ in
            guard let origin = self?.presenter.origin else {
                return
            }

            DispatchQueue.main.async {
                self?.frame.origin = origin
                self?.linkLine?.moveEnd(to: origin)
            }
        }).store(in: &cancellables)

        presenter.$isResizing.sink(receiveValue: { [weak self] _ in
            DispatchQueue.main.async {
                self?.resize()
            }
        }).store(in: &cancellables)

        presenter.$addedPart.sink(receiveValue: { [weak self] addedPart in
            guard let addedPart = addedPart else {
                return
            }
            DispatchQueue.main.async {
                self?.parts.addArrangedSubview(addedPart.toView())
            }
        }).store(in: &cancellables)

        presenter.$isRemoved.sink(receiveValue: { [weak self] isRemoved in
            if isRemoved {
                DispatchQueue.main.async {
                    self?.removeFromSuperview()
                    self?.linkLine?.removeFromSuperview()
                }
            }
        }).store(in: &cancellables)

        presenter.$modelWasUpdated.sink { [weak self] modelWasUpdated in
            if modelWasUpdated {
                DispatchQueue.main.async {
                    self?.parts.arrangedSubviews.forEach({ $0.removeFromSuperview() })

                    self?.populateParts()

                    self?.resize()
                }
            }
        }.store(in: &cancellables)

        presenter.$conflictIdx.sink { [weak self] conflictIdx in
            guard conflictIdx == nil else {
                return
            }
            guard let self = self else {
                return
            }
            guard self.presenter.resolveBySave,
                let mergeConflictsPalette = self.mergeConflictsPalette else {
                return
            }
            let mergeConflictsHeight = mergeConflictsPalette.height
            DispatchQueue.main.async {
                mergeConflictsPalette.resetDimensions()
                mergeConflictsPalette.removeFromSuperview()
                self.mergeConflictsPalette = nil

                self.palette.translateUp(by: mergeConflictsHeight)

                let scrollNewOrigin = CGPoint(x: self.scroll.frame.origin.x,
                                              y: self.scroll.frame.origin.y - mergeConflictsHeight)
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
        presenter.inFocus()
    }

    @objc
    private func didPan(_ sender: UIPanGestureRecognizer) {
        guard let superview = superview else {
            return
        }
        let previousCenter = presenter.center
        superview.bringSubviewToFront(self)
        let translation = sender.translation(in: superview)
        presenter.translateCenter(by: translation)
        sender.setTranslation(.zero, in: superview)

        if presenter.hasExceededBounds(bounds: superview.bounds) {
            presenter.center = previousCenter
        }
    }

    private func resize() {
        parts.frame = presenter.partsFrame
        self.frame = presenter.frame
    }
}
