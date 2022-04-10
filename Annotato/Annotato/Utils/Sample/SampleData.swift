import CoreGraphics
import Foundation
import AnnotatoSharedLibrary

class SampleData {
    static var exampleDocument: Document {
        Document(name: "Clean Code", ownerId: "owner123", id: UUID())
    }

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
}
