import CoreGraphics
import Foundation

class SampleData {
    func exampleDocumentsInList() -> [DocumentListViewModel] {
        [
            DocumentListViewModel(name: "Test A"),
            DocumentListViewModel(name: "Test B"),
            DocumentListViewModel(name: "Test C"),
            DocumentListViewModel(name: "Test D"),
            DocumentListViewModel(name: "Test E")
        ]
    }

    func exampleDocument() -> DocumentViewModel {
        DocumentViewModel(annotations: SampleData().exampleAnnotations())
    }

    private func exampleAnnotations() -> [AnnotationViewModel] {
        [
            AnnotationViewModel(
                id: UUID(),
                origin: CGPoint(x: 100.0, y: 150.0),
                width: 300.0,
                parts: []
            )
        ]
    }

//    private func exampleAnnotations() -> [DocumentAnnotationViewModel] {
//        [
//            DocumentAnnotationViewModel(
//                center: CGPoint(x: 450.0, y: 150.0),
//                width: 300.0,
//                parts: exampleAnnotationParts1()
//            ),
//            DocumentAnnotationViewModel(
//                center: CGPoint(x: 600.0, y: 300.0),
//                width: 250.0,
//                parts: exampleAnnotationParts2())
//        ]
//    }

//    private func exampleAnnotationParts1() -> [DocumentAnnotationPartViewModel] {
//        [
//            DocumentAnnotationTextViewModel(id: UUID(), content: "I am hungry", height: 30.0),
//            DocumentAnnotationTextViewModel(id: UUID(), content: "ABC\nDEF", height: 60.0)
//        ]
//    }
//
//    private func exampleAnnotationParts2() -> [DocumentAnnotationPartViewModel] {
//        [
//            DocumentAnnotationTextViewModel(
//                id: UUID(),
//                content: "Lorem ipsum dolor sit amet, consectetur adipiscing elit.",
//                height: 44.0),
//            DocumentAnnotationTextViewModel(
//                id: UUID(),
//                content: "Hello\nHello\nHello",
//                height: 60.0)
//        ]
//    }
}
