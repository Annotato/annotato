import UIKit
import AnnotatoSharedLibrary

class DocumentAnnotationToolbarView: UIToolbar {
    weak var actionDelegate: DocumentAnnotationToolbarDelegate? {
        didSet {
            enterEditOrViewMode()
        }
    }
    private var annotationViewModel: DocumentAnnotationViewModel

    private var textButton = UIBarButtonItem()
    private var markdownButton = UIBarButtonItem()
    private var editButton = UIBarButtonItem()
    private var paletteButtons: [AnnotationType: ToggleableButton] = [:]

    @available(*, unavailable)
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    init(frame: CGRect,
         annotationViewModel: DocumentAnnotationViewModel
    ) {
        self.annotationViewModel = annotationViewModel
        super.init(frame: frame)

        textButton = makeTextButton()
        markdownButton = makeMarkdownButton()
        initializeEditButton(isEditable: annotationViewModel.isNew)
        initializePalette(startingAnnotationType: annotationViewModel.startingAnnotationType)
        self.items = [textButton, markdownButton, flexibleSpace, editButton]
    }

    private func makeTextButton() -> UIBarButtonItem {
        let button = makeToggleableButtonSystemItem(systemName: "textformat")
        paletteButtons[.plainText] = button
        button.addTarget(self, action: #selector(didTapTextButton), for: .touchUpInside)
        return UIBarButtonItem(customView: button)
    }

    private func makeMarkdownButton() -> UIBarButtonItem {
        let button = makeToggleableButtonSystemItem(systemName: "m.square")
        paletteButtons[.markdown] = button
        button.addTarget(self, action: #selector(didTapMarkdownButton), for: .touchUpInside)
        return UIBarButtonItem(customView: button)
    }

    private func makeToggleableButtonSystemItem(systemName: String) -> ToggleableButton {
        let button = ToggleableButton()
        button.setImage(UIImage(systemName: systemName), for: .normal)
        button.sizeToFit()
        button.tintColor = .darkGray
        button.delegate = self
        return button
    }

    private func initializeEditButton(isEditable: Bool) {
        if isEditable {
            editButton.isSelected = true
        } else {
            editButton.isSelected = false
        }
        setEditButtonView()
        enterEditOrViewMode()
    }

    private func initializePalette(startingAnnotationType: AnnotationType?) {
        guard let annotationType = startingAnnotationType else {
            return
        }

        switch annotationType {
        case .plainText:
            guard let button = paletteButtons[.plainText] else {
                return
            }
            button.isSelected = true
            didTapTextButton(button)
        case .markdown:
            guard let button = paletteButtons[.markdown] else {
                return
            }
            button.isSelected = true
            didTapMarkdownButton(button)
        }
    }

    private func setEditButtonView() {
        let imageName = editButton.isSelected ? "eye" : "pencil"
        let button = UIButton(type: .system)
        button.sizeToFit()
        button.setImage(UIImage(systemName: imageName), for: .normal)
        button.addTarget(self, action: #selector(didTapEditButton), for: .touchUpInside)
        editButton.customView = button
    }

    @objc
    private func didTapEditButton() {
        editButton.isSelected.toggle()
        setEditButtonView()
        enterEditOrViewMode()
    }

    private func enterEditOrViewMode() {
        if editButton.isSelected {
            enablePalette()
            actionDelegate?.enterEditMode()
        } else {
            disablePalette()
            actionDelegate?.enterViewMode()
        }
    }

    private func enablePalette() {
        for paletteButton in paletteButtons.values {
            paletteButton.isEnabled = true
        }
    }

    private func disablePalette() {
        for paletteButton in paletteButtons.values {
            paletteButton.isEnabled = false
        }
    }
}

extension DocumentAnnotationToolbarView: ToggleableButtonDelegate {
    func didSelect(button: ToggleableButton) {
        for paletteButton in paletteButtons.values where paletteButton != button {
            paletteButton.isSelected = false
        }
    }

    @objc
    private func didTapTextButton(_ sender: ToggleableButton) {
        if sender.isSelected {
            actionDelegate?.addOrReplaceSection(with: .plainText)
        }
    }

    @objc
    private func didTapMarkdownButton(_ sender: ToggleableButton) {
        if sender.isSelected {
            actionDelegate?.addOrReplaceSection(with: .markdown)
        }
    }
}
