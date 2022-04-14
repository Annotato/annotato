import Foundation
import Combine
import CoreGraphics

class AnnotationMergeConflictsPaletteViewModel: ObservableObject {
    weak var parentViewModel: AnnotationViewModel?

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
        parentViewModel?.didSaveMergeConflicts()
    }

    func didTapDiscardMergeConflictsButton() {
        parentViewModel?.didDiscardMergeConflicts()
    }
}

extension AnnotationMergeConflictsPaletteViewModel {
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
