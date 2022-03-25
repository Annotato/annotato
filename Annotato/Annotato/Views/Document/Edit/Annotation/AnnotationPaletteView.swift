import UIKit
import Combine

class AnnotationPaletteView: UIToolbar {
    private(set) var viewModel: AnnotationPaletteViewModel
    private(set) var textButton: ToggleableButton
    private(set) var markdownButton: ToggleableButton
    private(set) var handwritingButton: ToggleableButton
    private(set) var editOrViewButton: ImageToggleableButton
    private(set) var deleteButton: UIButton
    private(set) var minimizeOrMaximizeButton: ImageToggleableButton

    private var cancellables: Set<AnyCancellable> = []

    @available(*, unavailable)
    required init(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    init(viewModel: AnnotationPaletteViewModel) {
        self.viewModel = viewModel
        self.textButton = AnnotationPaletteView.makeToggleableSystemButton(
            systemName: SystemImageName.textformat.rawValue, color: .darkGray)
        self.markdownButton = AnnotationPaletteView.makeToggleableSystemButton(
            systemName: SystemImageName.mSquare.rawValue, color: .darkGray)
        self.handwritingButton = AnnotationPaletteView.makeToggleableSystemButton(
            systemName: SystemImageName.pencil.rawValue, color: .darkGray)
        self.editOrViewButton = ImageToggleableButton(
            selectedImage: UIImage(systemName: SystemImageName.eye.rawValue),
            unselectedImage: UIImage(systemName: SystemImageName.pencil.rawValue))
        self.deleteButton = AnnotationPaletteView.makeDeleteButton()
        self.minimizeOrMaximizeButton = ImageToggleableButton(
            selectedImage: UIImage(named: ImageName.maximizeIcon.rawValue),
            unselectedImage: UIImage(named: ImageName.minimizeIcon.rawValue))
        super.init(frame: viewModel.frame)

        setUpButtons()
        setUpSubscribers()
    }

    private func setUpButtons() {
        textButton.addTarget(self, action: #selector(didTap), for: .touchUpInside)
        markdownButton.addTarget(self, action: #selector(didTap), for: .touchUpInside)
        handwritingButton.addTarget(self, action: #selector(didTap), for: .touchUpInside)
        editOrViewButton.addTarget(self, action: #selector(didTapEditOrViewButton), for: .touchUpInside)
        deleteButton.addTarget(self, action: #selector(didTapDeleteButton), for: .touchUpInside)
        minimizeOrMaximizeButton.addTarget(
            self, action: #selector(didTapMinimizeOrMaximizeButton), for: .touchUpInside)
        minimizeOrMaximizeButton.imageView?.contentMode = .scaleAspectFit

        let textBarButton = UIBarButtonItem(customView: textButton)
        let markdownBarButton = UIBarButtonItem(customView: markdownButton)
        let handwritingBarButton = UIBarButtonItem(customView: handwritingButton)
        let editOrViewBarButton = UIBarButtonItem(customView: editOrViewButton)
        let deleteBarButton = UIBarButtonItem(customView: deleteButton)
        let minimizeOrMaximizeBarButton = UIBarButtonItem(customView: minimizeOrMaximizeButton)
        minimizeOrMaximizeButton.widthAnchor.constraint(equalToConstant: 20.0).isActive = true
        minimizeOrMaximizeButton.isSelected = viewModel.isMinimized
        self.items = [
            textBarButton,
            spaceBetween,
            markdownBarButton,
            spaceBetween,
            handwritingBarButton,
            flexibleSpace,
            editOrViewBarButton,
            spaceBetween,
            deleteBarButton,
            spaceBetween,
            minimizeOrMaximizeBarButton
        ]
    }

    private func setUpSubscribers() {
        viewModel.$textIsSelected.sink(receiveValue: { [weak self] textIsSelected in
            self?.textButton.isSelected = textIsSelected
        }).store(in: &cancellables)

        viewModel.$markdownIsSelected.sink(receiveValue: { [weak self] markdownIsSelected in
            self?.markdownButton.isSelected = markdownIsSelected
        }).store(in: &cancellables)

        viewModel.$handwritingIsSelected.sink(receiveValue: { [weak self] handwritingIsSelected in
            self?.handwritingButton.isSelected = handwritingIsSelected
        }).store(in: &cancellables)

        viewModel.$isEditing.sink(receiveValue: { [weak self] isEditing in
            self?.textButton.isHidden = !isEditing
            self?.markdownButton.isHidden = !isEditing
            self?.handwritingButton.isHidden = !isEditing
            self?.editOrViewButton.isSelected = isEditing
            self?.minimizeOrMaximizeButton.isHidden = isEditing
        }).store(in: &cancellables)

        viewModel.$isMinimized.sink(receiveValue: { [weak self] isMinimized in
            self?.minimizeOrMaximizeButton.isSelected = isMinimized
        }).store(in: &cancellables)
    }
}

extension AnnotationPaletteView {
    var annotationTypeButtons: [ToggleableButton] {
        [textButton, markdownButton, handwritingButton]
    }

    @objc
    private func didTap(toggleableButton: ToggleableButton) {
        for annotationTypeButton in annotationTypeButtons where annotationTypeButton != toggleableButton {
            annotationTypeButton.isSelected = false
        }

        if toggleableButton == textButton {
            viewModel.didSelectTextButton()
        }

        if toggleableButton == markdownButton {
            viewModel.didSelectMarkdownButton()
        }

        if toggleableButton == handwritingButton {
            viewModel.didSelectHandwritingButton()
        }
    }

    @objc
    private func didTapEditOrViewButton(_ button: UIButton) {
        editOrViewButton.isSelected.toggle()

        let isNowEditing = editOrViewButton.isSelected
        if isNowEditing {
            viewModel.enterEditMode()
            viewModel.enterMaximizedMode()
        } else {
            viewModel.enterViewMode()
        }
    }

    @objc
    private func didTapDeleteButton(_ button: UIButton) {
        viewModel.didSelectDeleteButton()
    }

    @objc
    private func didTapMinimizeOrMaximizeButton(_ button: UIButton) {
        viewModel.didSelectMinimizeOrMaximizeButton()
    }
}
