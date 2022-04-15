import Foundation
import Combine
import CoreGraphics

class AnnotationMergeConflictsPalettePresenter: ObservableObject {
    weak var parentPresenter: AnnotationPresenter?

    private(set) var origin: CGPoint
    private(set) var width: Double
    private(set) var height: Double
    private(set) var conflictIdx: Int

    init(origin: CGPoint, width: Double, height: Double, conflictIdx: Int) {
        self.origin = origin
        self.width = width
        self.height = height
        self.conflictIdx = conflictIdx
    }

    func didTapSaveMergeConflictsButton() {
        parentPresenter?.didSaveMergeConflicts()
    }

    func didTapDiscardMergeConflictsButton() {
        parentPresenter?.didDiscardMergeConflicts()
    }
}

extension AnnotationMergeConflictsPalettePresenter {
    var size: CGSize {
        CGSize(width: width, height: height)
    }

    var frame: CGRect {
        CGRect(origin: origin, size: size)
    }

    func resetDimensions() {
        width = 0.0
        height = 0.0
    }
}
