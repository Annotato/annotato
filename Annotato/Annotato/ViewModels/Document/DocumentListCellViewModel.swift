import Foundation
import AnnotatoSharedLibrary

class DocumentListCellViewModel {
    let usersPersistenceManager = UsersPersistenceManager()
    private(set) var usersSharingDocument: [UserViewModel] = []

    let document: Document
    let isShared: Bool

    var id: UUID {
        document.id
    }

    var name: String {
        document.name
    }

    var ownerId: String {
        document.ownerId
    }

    init(document: Document, isShared: Bool) {
        self.document = document
        self.isShared = isShared
    }

    func canFindUsersSharingDocument() async -> Bool {
        let usersSharingDocumentModels = await usersPersistenceManager
            .getUsersSharingDocument(documentId: document.id) ?? []

        usersSharingDocument = usersSharingDocumentModels.map { UserViewModel(model: $0) }

        return !usersSharingDocument.isEmpty
    }
}
