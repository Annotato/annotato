import UIKit

class DocumentAnnotationView: UIView {
    private var viewModel: DocumentAnnotationViewModel
    private var sections: [DocumentAnnotationSectionView] = []
    let toolbarHeight = 50.0
    let minHeight: Double
    let maxHeight: Double
    let scrollViewMinHeight = 50.0
    let scrollViewMaxHeight = 200.0
    private var scrollView = UIScrollView()
    private var stackView = UIStackView()

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
        addPanGestureRecognizer()
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

    private func resizeStackView() {
        var newStackViewFrame = stackView.frame
        newStackViewFrame.size.height = sectionsHeight
        stackView.frame = newStackViewFrame
    }

    private func resize() {
        var newAnnotationFrame = self.frame
        let targetAnnotationHeight = toolbarHeight + sectionsHeight
        newAnnotationFrame.size.height = min(maxHeight, max(minHeight, targetAnnotationHeight))
        self.frame = newAnnotationFrame
    }
}

extension DocumentAnnotationView: UITextViewDelegate {
    func textViewDidChange(_ textView: UITextView) {
        let fixedWidth = textView.frame.size.width
        let newSize = textView.sizeThatFits(CGSize(width: fixedWidth, height: CGFloat.greatestFiniteMagnitude))
        textView.frame.size = CGSize(width: max(newSize.width, fixedWidth), height: newSize.height)

        resizeStackView()
        resize()
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
            resizeStackView()
            resize()
            return
        }

        switch annotationType {
        case .plainText:
            let newTextViewModel = DocumentAnnotationTextViewModel(content: "", height: 50.0)
            let newSection = newTextViewModel.toView(in: self)
            sections.append(newSection)
            stackView.addArrangedSubview(newSection)
        case .markdown:
            let newMarkdownViewModel = DocumentAnnotationMarkdownViewModel(content: "", height: 50.0)
            let newSection = newMarkdownViewModel.toView(in: self)
            sections.append(newSection)
            stackView.addArrangedSubview(newSection)
        }

        resizeStackView()
        resize()
    }
}
