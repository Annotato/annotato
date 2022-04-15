import UIKit

class AnnotationMergeConflictsPaletteView: UIToolbar {
    private(set) var presenter: AnnotationMergeConflictsPalettePresenter
    private(set) var saveMergeConflictsButton: UIButton
    private(set) var discardMergeConflictsButton: UIButton
    private(set) var conflictIdxButton: UIButton

    @available(*, unavailable)
    required init(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    init(presenter: AnnotationMergeConflictsPalettePresenter) {
        self.presenter = presenter
        self.saveMergeConflictsButton = AnnotationMergeConflictsPaletteView.makeSaveButton()
        self.discardMergeConflictsButton = AnnotationMergeConflictsPaletteView.makeDiscardButton()
        self.conflictIdxButton = AnnotationMergeConflictsPaletteView.makeConflictIndexButton(
            conflictIdx: presenter.conflictIdx)

        super.init(frame: presenter.frame)
        self.layer.borderWidth = 1.0
        self.layer.borderColor = UIColor.black.cgColor
        setUpButtons()
    }

    private func setUpButtons() {
        saveMergeConflictsButton.addTarget(
            self, action: #selector(didTapSaveMergeConflictsButton), for: .touchUpInside)
        discardMergeConflictsButton.addTarget(
            self, action: #selector(didTapDiscardMergeConflictsButton), for: .touchUpInside)

        let saveMergeConflictsButton = UIBarButtonItem(customView: saveMergeConflictsButton)
        let discardMergeConflictsButton = UIBarButtonItem(customView: discardMergeConflictsButton)
        let conflictIdxButton = UIBarButtonItem(customView: conflictIdxButton)

        self.items = [
            saveMergeConflictsButton,
            spaceBetween,
            discardMergeConflictsButton,
            flexibleSpace,
            conflictIdxButton
        ]
    }

    @objc
    private func didTapSaveMergeConflictsButton(_ button: UIButton) {
        presenter.didTapSaveMergeConflictsButton()
    }

    @objc
    private func didTapDiscardMergeConflictsButton(_ button: UIButton) {
        presenter.didTapDiscardMergeConflictsButton()
    }
}

extension AnnotationMergeConflictsPaletteView {
    var height: CGFloat {
        presenter.height
    }

    func resetDimensions() {
        presenter.resetDimensions()
        self.frame = presenter.frame
    }
}

extension AnnotationMergeConflictsPaletteView {
    class func makeSaveButton() -> UIButton {
        makeTextButton(label: "Save")
    }

    class func makeDiscardButton() -> UIButton {
        makeTextButton(label: "Discard")
    }

    class func makeConflictIndexButton(conflictIdx: Int) -> UIButton {
        let button = UIButton()
        button.setTitle(String(conflictIdx), for: .normal)
        button.setTitleColor(UIColor.red, for: .normal)
        return button
    }
}
