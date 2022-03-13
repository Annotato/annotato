import Foundation

class DocumentListViewModel {
    private(set) var name: String
    private(set) var url: URL

    init(name: String, url: URL) {
        self.name = name
        self.url = url
    }

}
