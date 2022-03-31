import Foundation
import AnnotatoSharedLibrary

struct AnnotatoDocumentSharesPersistence: DocumentSharesPersistence {
    func createDocumentShare(documentShare: DocumentShare) async -> DocumentShare? {
        if WebSocketManager.shared.isConnected {
            guard let createdDocumentShareRemote = await AnnotatoPersistence
                .remotePersistence
                .documentShares
                .createDocumentShare(documentShare: documentShare) else {
                AnnotatoLogger.error("DocumentShare was not created remotely",
                                     context: "AnnotatoDocumentSharesPersistence::createDocumentShare")
                return nil
            }
            guard let createdDocumentShareLocal = await AnnotatoPersistence
                .localPersistence
                .documentShares
                .createDocumentShare(documentShare: createdDocumentShareRemote) else {
                AnnotatoLogger.error("DocumentShare was not created locally",
                                     context: "AnnotatoDocumentSharesPersistence::createDocumentShare")
                return nil
            }
            // TODO: Set valid bit to 1
            return createdDocumentShareLocal

        } else {
            guard let createdDocumentShareLocal = await AnnotatoPersistence
                .localPersistence
                .documentShares
                .createDocumentShare(documentShare: documentShare) else {
                AnnotatoLogger.error("DocumentShare was not created locally",
                                     context: "AnnotatoDocumentSharesPersistence::createDocumentShare")
                return nil
            }
            // TODO: Set valid bit to 0
            return createdDocumentShareLocal
        }
    }
}
