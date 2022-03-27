import Foundation
import AnnotatoSharedLibrary

class DocumentListViewModel {
    let document: Document
    let isShared: Bool

    var id: UUID {
        document.id
    }

    var name: String {
        document.name
    }

    init(document: Document, isShared: Bool) {
        self.document = document
        self.isShared = isShared
    }
}
