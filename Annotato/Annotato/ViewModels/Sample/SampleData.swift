import CoreGraphics
import Foundation

class SampleData {
    func exampleDocumentsInList() -> [DocumentListViewModel] {
        [
            DocumentListViewModel(name: "Lab01 Qns", baseFileUrl: exampleUrlLab01Qns()),
            DocumentListViewModel(name: "L0 Overview", baseFileUrl: exampleUrlL0Overview()),
            DocumentListViewModel(name: "L1 Intro", baseFileUrl: exampleUrlL1Intro()),
            DocumentListViewModel(name: "Firebase Clean Code", baseFileUrl: exampleUrlFirebase()),
            DocumentListViewModel(name: "Test E", baseFileUrl: exampleUrlL0Overview())
        ]
    }

    func exampleDocument(from listViewModel: DocumentListViewModel) -> DocumentViewModel {
        let pdfDocument = PdfViewModel(baseFileUrl: listViewModel.baseFileUrl)
        return DocumentViewModel(annotations: [], pdfDocument: pdfDocument)
    }

    func exampleDocument() -> DocumentViewModel {
        DocumentViewModel(
            annotations: SampleData().exampleAnnotations(),
            pdfDocument: examplePdfViewModelLab01Qns()
        )
    }

    func exampleAnnotations() -> [AnnotationViewModel] {
        [
            AnnotationViewModel(
                id: UUID(),
                centerInDocumentSpace: CGPoint(x: 300.0, y: 300.0),
                associatedDocumentPdfViewModel: examplePdfViewModelLab01Qns(),
                pageNum: "1",
                width: 300.0,
                parts: exampleAnnotationParts1()
            ),
            AnnotationViewModel(
                id: UUID(),
                centerInDocumentSpace: CGPoint(x: 100.0, y: 150.0),
                associatedDocumentPdfViewModel: examplePdfViewModelLab01Qns(),
                pageNum: "0",
                width: 250.0,
                parts: exampleAnnotationParts1()
            )
        ]
    }

    private func examplePdfViewModelLab01Qns() -> PdfViewModel {
        PdfViewModel(baseFileUrl: exampleUrlLab01Qns())
    }

    private func examplePdfViewModelL0Overview() -> PdfViewModel {
        PdfViewModel(baseFileUrl: exampleUrlL0Overview())
    }

    private func exampleUrlLab01Qns() -> URL {
        guard let baseFileUrl = Bundle.main.url(forResource: "Lab01Qns", withExtension: "pdf") else {
            fatalError("example baseFileUrl not valid")
        }
        return baseFileUrl
    }

    private func exampleUrlL0Overview() -> URL {
        guard let baseFileUrl = Bundle.main.url(
            forResource: "L0 - Course Overview",
            withExtension: "pdf"
        ) else {
            fatalError("example baseFileUrl not valid")
        }
        return baseFileUrl
    }

    private func exampleUrlL1Intro() -> URL {
        guard let baseFileUrl = Bundle.main.url(forResource: "L1 - Introduction", withExtension: "pdf") else {
            fatalError("example baseFileUrl not valid")
        }
        return baseFileUrl
    }

    private func exampleUrlFirebase() -> URL {
        let firebaseUrlString = "https://firebasestorage.googleapis.com" +
            ":443/v0/b/annotato" + "-ba051.appspot.com/o/clean-cod" +
            "e.pdf?alt=media&token=513532aa-9c96-42ce-9a62-b4a49a8ec37c"
        let firebaseUrl = URL(string: firebaseUrlString)
        guard let firebaseUrl = firebaseUrl else {
            fatalError("firebase url not valid")
        }

        return firebaseUrl
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
