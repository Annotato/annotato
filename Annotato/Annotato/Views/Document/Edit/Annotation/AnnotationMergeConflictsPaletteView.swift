import UIKit

class AnnotationMergeConflictsPaletteView: UIToolbar {
    private(set) var viewModel: AnnotationMergeConflictsPalettePresenter
    private(set) var saveMergeConflictsButton: UIButton
    private(set) var discardMergeConflictsButton: UIButton
    private(set) var conflictIdxButton: UIButton

    @available(*, unavailable)
    required init(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    init(viewModel: AnnotationMergeConflictsPalettePresenter) {
        self.viewModel = viewModel
        self.saveMergeConflictsButton = AnnotationMergeConflictsPaletteView.makeSaveButton()
        self.discardMergeConflictsButton = AnnotationMergeConflictsPaletteView.makeDiscardButton()
        self.conflictIdxButton = AnnotationMergeConflictsPaletteView.makeConflictIndexButton(
            conflictIdx: viewModel.conflictIdx)

        super.init(frame: viewModel.frame)
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
        viewModel.didTapSaveMergeConflictsButton()
    }

    @objc
    private func didTapDiscardMergeConflictsButton(_ button: UIButton) {
        viewModel.didTapDiscardMergeConflictsButton()
    }
}

extension AnnotationMergeConflictsPaletteView {
    var height: CGFloat {
        viewModel.height
    }

    func resetDimensions() {
        viewModel.resetDimensions()
        self.frame = viewModel.frame
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
