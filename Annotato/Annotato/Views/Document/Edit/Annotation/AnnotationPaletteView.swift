import UIKit

class AnnotationPaletteView: UIToolbar {
    private(set) var viewModel: AnnotationPaletteViewModel
    private(set) var textButton: ToggleableButton
    private(set) var markdownButton: ToggleableButton
    private(set) var editOrViewButton: EditOrViewButton
    private(set) var deleteButton: UIButton

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
    }

    private func setUpButtons() {
        textButton.delegate = self
        markdownButton.delegate = self
        editOrViewButton.delegate = self

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
}

extension AnnotationPaletteView: ToggleableButtonDelegate {
    var annotationTypeButtons: [ToggleableButton] {
        [textButton, markdownButton]
    }

    func didSelect(button: ToggleableButton) {
        for annotationTypeButton in annotationTypeButtons where annotationTypeButton != button {
            annotationTypeButton.isSelected = false
        }

        if button == textButton {
            viewModel.didSelectTextButton()
        }

        if button == markdownButton {
            viewModel.didSelectMarkdownButton()
        }
    }
}

extension AnnotationPaletteView: EditOrViewButtonDelegate {
    func changeMode() {
        editOrViewButton.isSelected ? viewModel.enterEditMode() : viewModel.enterViewMode()
    }
}
