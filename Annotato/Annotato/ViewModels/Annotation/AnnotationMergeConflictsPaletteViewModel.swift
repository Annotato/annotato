import Foundation
import Combine
import CoreGraphics

class AnnotationMergeConflictsPaletteViewModel: ObservableObject {
    weak var parentViewModel: AnnotationViewModel?

    private(set) var origin: CGPoint
    private(set) var width: Double
    private(set) var height: Double

    init(origin: CGPoint, width: Double, height: Double) {
        self.origin = origin
        self.width = width
        self.height = height
    }

    func didTapSaveMergeConflictsButton() {
        parentViewModel?.didSaveMergeConflicts()
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
