import UIKit
import Combine

class AnnotationPaletteView: UIToolbar {
    private(set) var viewModel: AnnotationPaletteViewModel
    private(set) var textButton: ToggleableButton
    private(set) var markdownButton: ToggleableButton
    private(set) var editOrViewButton: EditOrViewButton
    private(set) var deleteButton: UIButton

    private var cancellables: Set<AnyCancellable> = []

    @available(*, unavailable)
    required init(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    init(viewModel: AnnotationPaletteViewModel) {
        self.viewModel = viewModel
        self.textButton = AnnotationPaletteView.makeToggleableSystemButton(
            systemName: "textformat", color: .darkGray)
        self.markdownButton = AnnotationPaletteView.makeToggleableSystemButton(
            systemName: "m.square", color: .darkGray)
        self.editOrViewButton = EditOrViewButton(isEditing: viewModel.isEditing)
        self.deleteButton = AnnotationPaletteView.makeDeleteButton()
        super.init(frame: viewModel.frame)

        setUpButtons()
        setUpSubscriber()
    }

    private func setUpButtons() {
        textButton.addTarget(self, action: #selector(didTap(toggleableButton: )), for: .touchUpInside)
        markdownButton.addTarget(self, action: #selector(didTap(toggleableButton: )), for: .touchUpInside)
        editOrViewButton.addTarget(self, action: #selector(didTapEditOrViewButton(_: )), for: .touchUpInside)
        deleteButton.addTarget(self, action: #selector(didTapDeleteButton(_: )), for: .touchUpInside)

        let textBarButton = UIBarButtonItem(customView: textButton)
        let markdownBarButton = UIBarButtonItem(customView: markdownButton)
        let editOrViewBarButton = UIBarButtonItem(customView: editOrViewButton)
        let deleteButton = UIBarButtonItem(customView: deleteButton)
        self.items = [textBarButton, markdownBarButton, flexibleSpace, editOrViewBarButton, deleteButton]
    }

    class func makeToggleableSystemButton(systemName: String, color: UIColor) -> ToggleableButton {
        let button = ToggleableButton()
        button.setImage(UIImage(systemName: systemName), for: .normal)
        button.tintColor = color
        return button
    }

    class func makeDeleteButton() -> UIButton {
        let button = UIButton()
        let imageName = "trash"
        button.setImage(UIImage(systemName: imageName), for: .normal)
        return button
    }

    private func setUpSubscriber() {
        viewModel.$textIsSelected.sink(receiveValue: { [weak self] textIsSelected in
            self?.textButton.isSelected = textIsSelected
        }).store(in: &cancellables)

        viewModel.$markdownIsSelected.sink(receiveValue: { [weak self] markdownIsSelected in
            self?.markdownButton.isSelected = markdownIsSelected
        }).store(in: &cancellables)
    }
}

extension AnnotationPaletteView {
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
    }

    @objc
    private func didTapEditOrViewButton(_ button: UIButton) {
        if editOrViewButton.isSelected {
            editOrViewButton.isSelected = false
            viewModel.enterViewMode()
        } else {
            editOrViewButton.isSelected = true
            viewModel.enterEditMode()
        }
    }

    @objc
    private func didTapDeleteButton(_ button: UIButton) {
        viewModel.didSelectDeleteButton()
    }

    var annotationTypeButtons: [ToggleableButton] {
        [textButton, markdownButton]
    }
}
