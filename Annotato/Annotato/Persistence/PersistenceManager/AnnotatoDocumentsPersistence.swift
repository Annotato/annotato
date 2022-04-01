import Foundation
import AnnotatoSharedLibrary

struct AnnotatoDocumentsPersistence: DocumentsPersistence {
    func getOwnDocuments(userId: String) async -> [Document]? {
        if WebSocketManager.shared.isConnected {
            guard let ownDocumentsRemote = await AnnotatoPersistence
                .remotePersistence
                .documents
                .getOwnDocuments(userId: userId) else {
                AnnotatoLogger.error("Failed to fetch own documents from remote")
                return nil
            }
            return ownDocumentsRemote

        } else {
            guard let ownDocumentsLocal = await AnnotatoPersistence
                .localPersistence
                .documents
                .getOwnDocuments(userId: userId) else {
                AnnotatoLogger.error("Failed to fetch own documents from local")
                return nil
            }
            return ownDocumentsLocal
        }
    }

    func getSharedDocuments(userId: String) async -> [Document]? {
        if WebSocketManager.shared.isConnected {
            guard let sharedDocumentsRemote = await AnnotatoPersistence
                .remotePersistence
                .documents
                .getSharedDocuments(userId: userId) else {
                AnnotatoLogger.error("Failed to fetch shared documents from remote")
                return nil
            }
            return sharedDocumentsRemote

        } else {
            guard let sharedDocumentsLocal = await AnnotatoPersistence
                .localPersistence
                .documents
                .getSharedDocuments(userId: userId) else {
                AnnotatoLogger.error("Failed to fetch shared documents from local")
                return nil
            }
            return sharedDocumentsLocal
        }
    }

    func getDocument(documentId: UUID) async -> Document? {
        if WebSocketManager.shared.isConnected {
            guard let remoteDocument = await AnnotatoPersistence
                .remotePersistence
                .documents
                .getDocument(documentId: documentId) else {
                AnnotatoLogger.error("Failed to fetch document from remote")
                return nil
            }
            return remoteDocument

        } else {
            guard let localDocument = await AnnotatoPersistence
                .localPersistence
                .documents
                .getDocument(documentId: documentId) else {
                AnnotatoLogger.error("Failed to fetch document from local")
                return nil
            }
            return localDocument
        }
    }

    func createDocument(document: Document) async -> Document? {
        if WebSocketManager.shared.isConnected {
            guard let createdDocumentRemote = await AnnotatoPersistence
                .remotePersistence
                .documents
                .createDocument(document: document) else {
                AnnotatoLogger.error("Failed to create document when saving to remote",
                                     context: "AnnotatoPersistence::createDocument")
                return nil
            }
            guard let createdDocumentLocal = await AnnotatoPersistence
                .localPersistence
                .documents
                .createDocument(document: createdDocumentRemote) else {
                AnnotatoLogger.error("Failed to create document when saving to local",
                                     context: "AnnotatoPersistence::createDocument")
                return nil
            }
            return createdDocumentLocal

        } else {
            guard let savedDocumentLocal = await AnnotatoPersistence
                .localPersistence
                .documents
                .createDocument(document: document) else {
                AnnotatoLogger.error("Failed to create document when saving to local",
                                     context: "AnnotatoPersistence::createDocument")
                return nil
            }
            return savedDocumentLocal
        }
    }

    func updateDocument(document: Document) async -> Document? {
        if WebSocketManager.shared.isConnected {
            guard let updatedDocumentRemote = await AnnotatoPersistence
                .remotePersistence
                .documents
                .updateDocument(document: document) else {
                AnnotatoLogger.error("Failed to update document remotely",
                                     context: "AnnotatoPersistence::updateDocument")
                return nil
            }
            guard let updatedDocumentLocal = await AnnotatoPersistence
                .localPersistence
                .documents
                .updateDocument(document: updatedDocumentRemote) else {
                AnnotatoLogger.error("Failed to update document locally",
                                     context: "AnnotatoPersistence::updateDocument")
                return nil
            }
            return updatedDocumentLocal

        } else {
            guard let updatedDocumentLocal = await AnnotatoPersistence
                .localPersistence
                .documents
                .updateDocument(document: document) else {
                AnnotatoLogger.error("Failed to update document locally",
                                     context: "AnnotatoPersistence::updateDocument")
                return nil
            }
            return updatedDocumentLocal
        }
    }

    func deleteDocument(document: Document) async -> Document? {
        if WebSocketManager.shared.isConnected {
            guard let deletedDocumentRemote = await AnnotatoPersistence
                .remotePersistence
                .documents
                .deleteDocument(document: document) else {
                AnnotatoLogger.error("Failed to delete document remotely")
                return nil
            }
            guard let deletedDocumentLocal = await AnnotatoPersistence
                .localPersistence
                .documents
                .deleteDocument(document: deletedDocumentRemote) else {
                AnnotatoLogger.error("Failed to delete document locally")
                return nil
            }
            return deletedDocumentLocal

        } else {
            guard let deletedDocumentLocal = await AnnotatoPersistence
                .localPersistence
                .documents
                .deleteDocument(document: document) else {
                AnnotatoLogger.error("Failed to delete document locally")
                return nil
            }
            return deletedDocumentLocal
        }
    }
}
