import CoreGraphics
import Foundation

class SampleData {
    func exampleDocumentsInList() -> [DocumentListViewModel] {
        [
            DocumentListViewModel(name: "Test A", url: exampleUrlLab01Qns()),
            DocumentListViewModel(name: "Test B", url: exampleUrlL0Overview()),
            DocumentListViewModel(name: "Test C", url: exampleUrlL1Intro()),
            DocumentListViewModel(name: "Test D", url: exampleUrlLab01Qns()),
            DocumentListViewModel(name: "Test E", url: exampleUrlL0Overview())
        ]
    }

    func exampleDocument() -> DocumentViewModel {
        DocumentViewModel(
            annotations: SampleData().exampleAnnotations(),
            pdfDocument: SampleData().examplePdfDocument())
    }

    func exampleAnnotations() -> [DocumentAnnotationViewModel] {
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
        DocumentPdfViewModel(url: SampleData().exampleUrlLab01Qns())
    }

    private func exampleUrlLab01Qns() -> URL {
        guard let url = Bundle.main.url(forResource: "Lab01Qns", withExtension: "pdf") else {
            fatalError("example url not valid")
        }
        return url
    }

    private func exampleUrlL0Overview() -> URL {
        guard let url = Bundle.main.url(
            forResource: "L0 - Course Overview",
            withExtension: "pdf"
        ) else {
            fatalError("example url not valid")
        }
        return url
    }

    private func exampleUrlL1Intro() -> URL {
        guard let url = Bundle.main.url(forResource: "L1 - Introduction", withExtension: "pdf") else {
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
