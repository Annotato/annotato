import UIKit

class AnnotationMergeConflictsPaletteView: UIToolbar {
    private(set) var viewModel: AnnotationMergeConflictsPaletteViewModel
    private(set) var saveMergeConflictsButton: UIButton
    private(set) var discardMergeConflictsButton: UIButton

    @available(*, unavailable)
    required init(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    init(viewModel: AnnotationMergeConflictsPaletteViewModel) {
        self.viewModel = viewModel
        self.saveMergeConflictsButton = AnnotationMergeConflictsPaletteView.makeSaveButton()
        self.discardMergeConflictsButton = AnnotationMergeConflictsPaletteView.makeDiscardButton()

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

        self.items = [
            saveMergeConflictsButton,
            spaceBetween,
            discardMergeConflictsButton
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
    }
}
