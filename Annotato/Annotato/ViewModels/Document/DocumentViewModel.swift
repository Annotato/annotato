import CoreGraphics
import Foundation

class DocumentViewModel: ObservableObject {
    private(set) var annotations: [AnnotationViewModel]
    @Published private(set) var annotationToAdd: AnnotationViewModel?

    init(annotations: [AnnotationViewModel]) {
        self.annotations = annotations
    }
}

extension DocumentViewModel {
    func addAnnotation(at point: CGPoint) {
        let newAnnotation = AnnotationViewModel(
            id: UUID(), origin: .zero, width: 300.0, parts: [])
        newAnnotation.center = point
        newAnnotation.enterEditMode()
        annotations.append(newAnnotation)
        annotationToAdd = newAnnotation
    }
}
