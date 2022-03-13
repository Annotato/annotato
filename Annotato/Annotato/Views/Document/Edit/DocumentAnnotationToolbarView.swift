import UIKit

class DocumentAnnotationToolbarView: UIToolbar {
    weak var actionDelegate: DocumentAnnotationToolbarDelegate?

    private var textButton = UIBarButtonItem()
    private var editButton = UIBarButtonItem()

    @available(*, unavailable)
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    init(frame: CGRect, isEditable: Bool = false) {
        super.init(frame: frame)

        initializeEditButton(isEditable: isEditable)
        textButton = makeTextButton()
        self.items = [textButton, flexibleSpace, editButton]
    }

    private func makeTextButton() -> UIBarButtonItem {
        let button = UIButton(type: .system)
        let textFormatName = "textformat"
        button.setImage(UIImage(systemName: textFormatName), for: .normal)
        button.sizeToFit()
        return UIBarButtonItem(customView: button)
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
            actionDelegate?.enterEditMode()
        } else {
            actionDelegate?.enterViewMode()
        }
    }
}
