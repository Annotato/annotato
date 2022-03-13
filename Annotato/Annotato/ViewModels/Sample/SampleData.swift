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
        DocumentViewModel(
            annotations: SampleData().exampleAnnotations(),
            pdfDocument: SampleData().examplePdfDocument())
    }

    private func exampleAnnotations() -> [DocumentAnnotationViewModel] {
        [
            DocumentAnnotationViewModel(
                center: CGPoint(x: 450.0, y: 150.0),
                width: 300.0,
                parts: exampleAnnotationParts1()
            ),
            DocumentAnnotationViewModel(
                center: CGPoint(x: 600.0, y: 300.0),
                width: 250.0,
                parts: exampleAnnotationParts2())
        ]
    }

    private func examplePdfDocument() -> DocumentPdfViewModel {
        DocumentPdfViewModel(url: SampleData().exampleUrl())
    }

    private func exampleUrl() -> URL {
        guard let url = Bundle.main.url(forResource: "Lab01Qns", withExtension: "pdf") else {
            print("No such pdf")
            fatalError("example url not valid")
        }
        return url
    }

    private func exampleAnnotationParts1() -> [DocumentAnnotationPartViewModel] {
        [
            DocumentAnnotationTextViewModel(content: "I am hungry", height: 30.0),
            DocumentAnnotationTextViewModel(content: "ABC\nDEF", height: 60.0)
        ]
    }

    private func exampleAnnotationParts2() -> [DocumentAnnotationPartViewModel] {
        [
            DocumentAnnotationTextViewModel(
                content: "Lorem ipsum dolor sit amet, consectetur adipiscing elit.",
                height: 44.0),
            DocumentAnnotationTextViewModel(content: "Hello\nHello\nHello", height: 60.0)
        ]
    }
}
