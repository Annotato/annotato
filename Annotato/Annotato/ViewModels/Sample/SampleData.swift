import CoreGraphics
import Foundation
import AnnotatoSharedLibrary

class SampleData {
    static var exampleDocumentsInList: [DocumentListViewModel] =
        [
            DocumentListViewModel(id: UUID(), name: "Lab01 Qns"),
            DocumentListViewModel(id: UUID(), name: "L0 Overview"),
            DocumentListViewModel(id: UUID(), name: "L1 Intro"),
            DocumentListViewModel(id: UUID(), name: "Firebase Clean Code"),
            DocumentListViewModel(id: UUID(), name: "Test E")
        ]
    }

    func exampleDocument(from listViewModel: DocumentListViewModel) -> DocumentViewModel {
        let pdfDocument = PdfViewModel(baseFileUrl: listViewModel.baseFileUrl)
        return DocumentViewModel(annotations: SampleData().exampleAnnotations(), pdfDocument: pdfDocument)
    }

    func exampleDocument() -> DocumentViewModel {
        DocumentViewModel(
            annotations: SampleData().exampleAnnotations(),
            pdfDocument: examplePdfViewModelLab01Qns()
        )
    }

    static var exampleDocument: Document {
        Document(name: "Clean Code", ownerId: "owner123", baseFileUrl: firebasePdfUrlString, id: UUID())
    }

    static var exampleAnnotations: [AnnotationViewModel] =
        [
            AnnotationViewModel(
                id: UUID(),
                origin: CGPoint(x: 100, y: 100),
                width: 300.0,
                parts: exampleAnnotationParts1
            ),
            AnnotationViewModel(
                id: UUID(),
                origin: CGPoint(x: 200, y: 900),
                width: 250.0,
                parts: exampleAnnotationParts1)
        ]

    static var examplePdfDocument: DocumentPdfViewModel =
        DocumentPdfViewModel(baseFileUrl: exampleUrlLab01Qns)

    static var exampleUrlLab01Qns: URL {
        guard let baseFileUrl = Bundle.main.url(forResource: "Lab01Qns", withExtension: "pdf") else {
            fatalError("example baseFileUrl not valid")
        }
        return baseFileUrl
    }

    static var exampleUrlL0Overview: URL {
        guard let baseFileUrl = Bundle.main.url(
            forResource: "L0 - Course Overview",
            withExtension: "pdf"
        ) else {
            fatalError("example baseFileUrl not valid")
        }
        return baseFileUrl
    }

    static var exampleUrlL1Intro: URL {
        guard let baseFileUrl = Bundle.main.url(forResource: "L1 - Introduction", withExtension: "pdf") else {
            fatalError("example baseFileUrl not valid")
        }
        return baseFileUrl
    }

    private static var firebasePdfUrlString =
        "https://firebasestorage.googleapis.com" +
        ":443/v0/b/annotato" + "-ba051.appspot.com/o/clean-cod" +
        "e.pdf?alt=media&token=513532aa-9c96-42ce-9a62-b4a49a8ec37c"

    private static var exampleUrlFirebase: URL {
        guard let firebaseUrl = URL(string: firebasePdfUrlString) else {
            fatalError("firebase url not valid")
        }

        return firebaseUrl
    }

    static var exampleAnnotationParts1: [AnnotationPartViewModel] =
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
