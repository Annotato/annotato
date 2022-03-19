import Foundation
import AnnotatoSharedLibrary

class DocumentListViewModel {
    let id: UUID
    private(set) var name: String

    init(id: UUID, name: String) {
        self.id = id
        self.name = name
    }

    convenience init(document: Document) {
        self.init(id: document.id, name: document.name)
    }
}
