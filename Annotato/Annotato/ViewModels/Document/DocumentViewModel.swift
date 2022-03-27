import CoreGraphics
import Foundation
import AnnotatoSharedLibrary
import Combine

class DocumentViewModel: ObservableObject {
    let model: Document
    private var cancellables: Set<AnyCancellable> = []

    private(set) var annotations: [AnnotationViewModel] = []
    private(set) var pdfDocument: PdfViewModel

    @Published private(set) var addedAnnotation: AnnotationViewModel?

    init?(model: Document) {
        guard let baseFileUrl = URL(string: model.baseFileUrl) else {
            return nil
        }
        self.model = model
        self.pdfDocument = PdfViewModel(baseFileUrl: baseFileUrl)
        self.annotations = model.annotations.map { AnnotationViewModel(model: $0, document: self) }
        setUpSubscribers()
    }

    private func setUpSubscribers() {
        for annotation in annotations {
            annotation.$isInFocus.sink(receiveValue: { [weak self] isInFocus in
                if isInFocus {
                    self?.setAllOtherAnnotationsOutOfFocus(except: annotation)
                }
            }).store(in: &cancellables)
        }
    }

    private func setUpSubscriberForAnnotation(annotation: AnnotationViewModel) {
        annotation.$isInFocus.sink(receiveValue: { [weak self] isInFocus in
            if isInFocus {
                self?.setAllOtherAnnotationsOutOfFocus(except: annotation)
            }
        }).store(in: &cancellables)
    }

    func setAllAnnotationsOutOfFocus() {
        for annotation in annotations {
            annotation.outOfFocus()
        }
    }

    private func setAllOtherAnnotationsOutOfFocus(except annotationInFocus: AnnotationViewModel) {
        for annotation in annotations where annotation.id != annotationInFocus.id {
            annotation.outOfFocus()
        }
    }
}

extension DocumentViewModel {
    func addAnnotationIfWithinBounds(center: CGPoint, bounds: CGRect) {
        guard let currentUser = AnnotatoAuth().currentUser else {
            return
        }

        let newAnnotationWidth = 300.0
        let newAnnotation = Annotation(
            origin: .zero,
            width: newAnnotationWidth,
            parts: [],
            ownerId: currentUser.uid,
            documentId: model.id,
            id: UUID()
        )
        model.addAnnotation(annotation: newAnnotation)

        let annotationViewModel = AnnotationViewModel(model: newAnnotation, document: self)
        annotationViewModel.center = center

        if annotationViewModel.hasExceededBounds(bounds: bounds) {
            model.removeAnnotation(annotation: newAnnotation)
            return
        }

        annotationViewModel.enterEditMode()
        annotationViewModel.enterMaximizedMode()
        annotations.append(annotationViewModel)
        addedAnnotation = annotationViewModel
        setUpSubscriberForAnnotation(annotation: annotationViewModel)
    }

    func removeAnnotation(annotation: AnnotationViewModel) {
        model.removeAnnotation(annotation: annotation.model)
        annotations.removeAll(where: { $0.model.id == annotation.model.id })
    }
}
