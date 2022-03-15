import CoreGraphics
import Foundation

class AnnotationViewModel {
    private(set) var id: UUID
    private(set) var origin: CGPoint
    private(set) var width: Double
    private(set) var parts: [AnnotationPartViewModel]
    private(set) var palette: AnnotationPaletteViewModel

    init(
        id: UUID,
        origin: CGPoint,
        width: Double,
        parts: [AnnotationPartViewModel],
        palette: AnnotationPaletteViewModel? = nil
    ) {
        self.id = id
        self.origin = origin
        self.width = width
        self.parts = parts
        self.palette = palette ?? AnnotationPaletteViewModel(origin: .zero, width: width, height: 50.0)
    }
}

// MARK: Position, Size
extension AnnotationViewModel {
    var height: Double {
        let totalPartHeights = parts.reduce(0, {acc, part in
            acc + part.height
        })

        return palette.height + totalPartHeights
    }

    var size: CGSize {
        CGSize(width: width, height: height)
    }

    var frame: CGRect {
        CGRect(origin: origin, size: size)
    }
}
