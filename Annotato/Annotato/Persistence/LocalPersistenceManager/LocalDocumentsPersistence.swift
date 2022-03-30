import Foundation
import AnnotatoSharedLibrary

struct LocalDocumentsPersistence: DocumentsPersistence {
    func getOwnDocuments(userId: String) -> [Document]? {
        // TODO: Implementation
        return nil
    }

    func getSharedDocuments(userId: String) -> [Document]? {
        // TODO: Implementation
        return nil
    }

    func getDocument(documentId: UUID) -> Document? {
        // TODO: Implementation
        return nil
    }

    func createDocument(document: Document) -> Document? {
        // TODO: Implementation
        return nil
    }

    func updateDocument(document: Document) -> Document? {
        // TODO: Implementation
        return nil
    }

    func deleteDocument(document: Document) -> Document? {
        // TODO: Implementation
        return nil
    }
}
