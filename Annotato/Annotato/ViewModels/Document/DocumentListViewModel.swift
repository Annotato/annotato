import Foundation

class DocumentListViewModel {
    let id: UUID
    private(set) var name: String
    private(set) var baseFileUrl: URL

    init(id: UUID, name: String, baseFileUrl: URL) {
        self.id = id
        self.name = name
        self.baseFileUrl = baseFileUrl
    }
}
