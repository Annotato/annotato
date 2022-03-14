import UIKit

class DocumentAnnotationView: UIView {
    weak var delegate: DocumentAnnotationDelegate?
    private var viewModel: DocumentAnnotationViewModel
    private var sections: [DocumentAnnotationSectionView] = []
    private var selectedSection: DocumentAnnotationSectionView?
    let toolbarHeight = 50.0
    let minHeight: Double
    let maxHeight: Double
    let scrollViewMinHeight = 50.0
    let scrollViewMaxHeight = 200.0
    private var scrollView = UIScrollView()
    private var stackView = UIStackView()
    private var toolbar: DocumentAnnotationToolbarView?

    @available(*, unavailable)
    required init(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    init(annotationViewModel: DocumentAnnotationViewModel) {
        self.viewModel = annotationViewModel
        let frame = CGRect(
            x: .zero,
            y: .zero,
            width: annotationViewModel.width,
            height: annotationViewModel.height + toolbarHeight
        )
        self.minHeight = toolbarHeight
        self.maxHeight = 200.0

        super.init(frame: frame)
        self.sections = viewModel.parts.map({ $0.toView(in: self) })
        self.center = annotationViewModel.center
        self.layer.borderWidth = 2
        self.layer.borderColor = UIColor.blue.cgColor
        makeScrollView()
        makeStackView()
        addGestureRecognizers()
        initializeSubviews()
    }

    private func initializeSubviews() {
        initializeToolbar()
        initializeScrollView()
    }

    private func makeScrollView() {
        scrollView = UIScrollView(
            frame: CGRect(
                x: .zero,
                y: toolbarHeight,
                width: frame.width,
                height: frame.height - toolbarHeight))
    }

    private var sectionsHeight: Double {
        sections.reduce(0, {accHeight, nextSection in
            accHeight + nextSection.frame.height
        })
    }

    private func makeStackView() {
        stackView = UIStackView(
            frame: CGRect(x: .zero, y: .zero, width: scrollView.frame.width, height: sectionsHeight))
        stackView.axis = .vertical
        stackView.distribution = .fillProportionally

        for section in sections {
            stackView.addArrangedSubview(section)
        }
    }

    private func initializeScrollView() {
        addSubview(scrollView)
        scrollView.translatesAutoresizingMaskIntoConstraints = false
        scrollView.leftAnchor.constraint(equalTo: leftAnchor).isActive = true
        scrollView.topAnchor.constraint(equalTo: topAnchor, constant: toolbarHeight).isActive = true
        scrollView.rightAnchor.constraint(equalTo: rightAnchor).isActive = true
        scrollView.bottomAnchor.constraint(equalTo: bottomAnchor).isActive = true

        scrollView.addSubview(stackView)
        stackView.leadingAnchor.constraint(equalTo: scrollView.leadingAnchor).isActive = true
        stackView.trailingAnchor.constraint(equalTo: scrollView.trailingAnchor).isActive = true
        stackView.bottomAnchor.constraint(equalTo: scrollView.bottomAnchor).isActive = true
        stackView.topAnchor.constraint(equalTo: scrollView.topAnchor).isActive = true
        stackView.widthAnchor.constraint(equalTo: scrollView.widthAnchor).isActive = true
    }

    private func initializeToolbar() {
        let toolbar = DocumentAnnotationToolbarView(
            frame: CGRect(x: .zero, y: .zero, width: frame.width, height: toolbarHeight),
            annotationViewModel: viewModel
        )
        toolbar.translatesAutoresizingMaskIntoConstraints = true
        toolbar.actionDelegate = self
        addSubview(toolbar)
        self.toolbar = toolbar
    }

    private func resizeStackView() {
        var newStackViewFrame = stackView.frame
        newStackViewFrame.size.height = sectionsHeight
        stackView.frame = newStackViewFrame
    }

    private func resizeAnnotationView() {
        var newAnnotationFrame = self.frame
        let targetAnnotationHeight = toolbarHeight + sectionsHeight
        newAnnotationFrame.size.height = min(maxHeight, max(minHeight, targetAnnotationHeight))
        self.frame = newAnnotationFrame
    }
}

extension DocumentAnnotationView: UITextViewDelegate {
    func resize() {
        resizeStackView()
        resizeAnnotationView()
    }

    func textViewDidChange(_ textView: UITextView) {
        let fixedWidth = textView.frame.size.width
        let newSize = textView.sizeThatFits(CGSize(width: fixedWidth, height: CGFloat.greatestFiniteMagnitude))
        textView.frame.size = CGSize(width: max(newSize.width, fixedWidth), height: newSize.height)

        resize()
    }

    func textViewDidBeginEditing(_ textView: UITextView) {
        guard let textView = textView as? DocumentAnnotationTextView else {
            return
        }

        toolbar?.tapButton(of: textView.annotationType)
    }

    func textViewDidEndEditing(_ textView: UITextView) {
        guard let textView = textView as? DocumentAnnotationTextView else {
            return
        }

        if textView.isEmpty {
            didBecomeEmpty(section: textView)
        }
    }
}

// MARK: Gestures
extension DocumentAnnotationView {
    func didResignFocus() {
        toolbar?.disableEdit()
    }

    func addGestureRecognizers() {
        addTapGestureRecognizer()
        addPanGestureRecognizer()
    }

    private func addTapGestureRecognizer() {
        isUserInteractionEnabled = true
        let gestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(didTap))
        addGestureRecognizer(gestureRecognizer)
    }

    @objc private func didTap() {
        delegate?.didSelect(selected: self)
    }

    private func addPanGestureRecognizer() {
        isUserInteractionEnabled = true
        let gestureRecognizer = UIPanGestureRecognizer(target: self, action: #selector(didPan))
        addGestureRecognizer(gestureRecognizer)
    }

    @objc
    private func didPan(_ sender: UIPanGestureRecognizer) {
        let touchPoint = sender.location(in: superview)

        if sender.state != .cancelled {
            sender.view?.center = touchPoint
        }
    }
}

extension DocumentAnnotationView: DocumentAnnotationSectionDelegate {
    func didSelect(section: DocumentAnnotationSectionView) {
        selectedSection = section
    }

    func didBecomeEmpty(section: DocumentAnnotationSectionView) {
        guard let lastSection = sections.last else {
            return
        }

        if section == lastSection {
            return
        }

        section.removeFromSuperview()
        sections.removeAll(where: { $0 == section })
        resize()
        selectedSection = nil
    }
}

extension DocumentAnnotationView: DocumentAnnotationToolbarDelegate {
    func enterEditMode() {
        for section in sections {
            section.enterEditMode()
        }
    }

    func enterViewMode() {
        for section in sections {
            section.enterViewMode()
        }
    }

    func addOrReplaceSection(with annotationType: AnnotationType) {
        guard let lastSection = sections.last else {
            return
        }

        if lastSection.annotationType == annotationType {
            return
        }

        if lastSection.isEmpty {
            let lastSection = sections.last
            lastSection?.removeFromSuperview()
            sections.removeLast()
        }

        if sections.last?.annotationType == annotationType {
            resize()
            return
        }

        addNewSection(basedOn: annotationType)
        resize()
    }

    private func addNewSection(basedOn annotationType: AnnotationType) {
        let newViewModel: DocumentAnnotationPartViewModel

        switch annotationType {
        case .plainText:
            newViewModel = DocumentAnnotationTextViewModel(content: "", height: 50.0)
        case .markdown:
            newViewModel = DocumentAnnotationMarkdownViewModel(content: "", height: 50.0)
        }

        let newSection = newViewModel.toView(in: self)
        sections.append(newSection)
        stackView.addArrangedSubview(newSection)
    }
}
