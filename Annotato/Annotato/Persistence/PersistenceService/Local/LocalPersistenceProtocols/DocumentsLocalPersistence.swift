import Foundation
import AnnotatoSharedLibrary

protocol DocumentsLocalPersistence {
    func getOwnDocuments(userId: String) -> [Document]?
    func getSharedDocuments(userId: String) -> [Document]?
    func getDocument(documentId: UUID) -> Document?
    func createDocument(document: Document) -> Document?
    func updateDocument(document: Document) -> Document?
    func deleteDocument(document: Document) -> Document?
    func createOrUpdateDocument(document: Document) -> Document?
    func createOrUpdateDocuments(documents: [Document]) -> [Document]?
}
