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
                parts: exampleAnnotationParts1()
            )
        ]
    }

    private func exampleAnnotationParts1() -> [AnnotationPartViewModel] {
        [
            AnnotationTextViewModel(
                id: UUID(),
                content: "hello world",
                width: 300.0,
                height: 30.0
            ),
            AnnotationMarkdownViewModel(
                id: UUID(),
                content: "some markdown",
                width: 300.0,
                height: 30.0
            ),
            AnnotationTextViewModel(
                id: UUID(),
                content: "more text",
                width: 300.0,
                height: 30.0
            )
        ]
    }
}
