import Foundation

class DocumentListViewModel {
    private(set) var name: String
    private(set) var baseFileUrl: URL

    init(name: String, baseFileUrl: URL) {
        self.name = name
        self.baseFileUrl = baseFileUrl
    }

}
