import Foundation
import Vapor
import AnnotatoSharedLibrary
import FluentKit

class OfflineToOnlineWebSocketController {
    private static var logger = Logger(label: "OfflineToOnlineWebSocketController")

    static func handleOfflineToOnlineResolution(userId: String, data: Data, db: Database) async {
        do {
            Self.logger.info("Processing offline to online data...")

            let message = try JSONCustomDecoder().decode(AnnotatoOfflineToOnlineMessage.self, from: data)

            switch message.mergeStrategy {
            case .duplicateConflicts:
                print("duplicate conflicts")
            case .keepServerVersion:
                print("keep server version")
            case .overrideServerVersion:
                await Self.handleOverrideServerVersion(userId: userId, db: db, message: message)
            }
        } catch {
            print(String(describing: error))
            Self.logger.error("Error when handling incoming offline to online data. \(error.localizedDescription)")
        }
    }

    private static func handleOverrideServerVersion(
        userId: String,
        db: Database,
        message: AnnotatoOfflineToOnlineMessage
    ) async {
        do {
            Self.logger.info("Processing override server data...")

            let documents = message.documents
            var responseDocuments: [Document] = []

            for document in documents {
                let resolvedDocument: Document

                if document.isDeleted {
                    resolvedDocument = try await DocumentsDataAccess.delete(
                        db: db, documentId: document.id)
                } else if await DocumentsDataAccess.canFindIncludingDeleted(db: db, documentId: document.id) {
                    resolvedDocument = try await DocumentsDataAccess.update(
                        db: db, documentId: document.id, document: document)
                } else {
                    resolvedDocument = try await DocumentsDataAccess.create(db: db, document: document)
                }

                responseDocuments.append(resolvedDocument)
            }

            let annotations = message.annotations
            var responseAnnotations: [Annotation] = []

            for annotation in annotations {
                let resolvedAnnotation: Annotation

                if annotation.isDeleted {
                    resolvedAnnotation = try await AnnotationDataAccess.delete(
                        db: db, annotationId: annotation.id)
                } else if await AnnotationDataAccess.canFindIncludingDeleted(db: db, annotationId: annotation.id) {
                    resolvedAnnotation = try await AnnotationDataAccess.update(
                        db: db, annotationId: annotation.id, annotation: annotation)
                } else {
                    resolvedAnnotation = try await AnnotationDataAccess.create(db: db, annotation: annotation)
                }

                responseAnnotations.append(resolvedAnnotation)
            }
        } catch {
            Self.logger.error("Error when overriding server version. \(error.localizedDescription)")
        }
    }
}
