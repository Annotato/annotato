import Foundation
import AnnotatoSharedLibrary

class DocumentListCellViewModel {
    let usersPersistenceManager = UsersPersistenceManager()
    private var usersSharingDocument: [AnnotatoUser] = []

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
        usersSharingDocument = await usersPersistenceManager.getUsersSharingDocument(documentId: document.id) ?? []
        return !usersSharingDocument.isEmpty
    }
}
