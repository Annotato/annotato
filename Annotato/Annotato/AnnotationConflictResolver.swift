import Foundation
import AnnotatoSharedLibrary

struct AnnotationConflictResolver {
    struct Resolution {
        var localCreate: [Annotation] = []
        var localUpdate: [Annotation] = []
        var localDelete: [Annotation] = []

        var serverCreate: [Annotation] = []
        var serverUpdate: [Annotation] = []
        var serverDelete: [Annotation] = []

        var models: [Annotation] = []
    }

    func resolve(localAnnotations: [Annotation], serverAnnotations: [Annotation]) -> Resolution {
        var resolution = Resolution()

        let localAnnotationsMap = Dictionary(uniqueKeysWithValues: localAnnotations.map({ ($0.id, $0) }))
        let serverAnnotationsMap = Dictionary(uniqueKeysWithValues: serverAnnotations.map({ ($0.id, $0) }))

        let localIds = Set(localAnnotations.map({ $0.id }))
        let serverIds = Set(serverAnnotations.map({ $0.id }))

        for localId in localIds where !serverIds.contains(localId) {
            let localAnnotation = localAnnotationsMap[localId]
            resolution.serverCreate.appendIfNotNil(localAnnotation)
            resolution.models.appendIfNotNil(localAnnotation)
        }

        for serverId in serverIds where !localIds.contains(serverId) {
            let serverAnnotation = serverAnnotationsMap[serverId]
            resolution.localCreate.appendIfNotNil(serverAnnotation)
            resolution.models.appendIfNotNil(serverAnnotation)
        }

        let commonIds = localIds.intersection(serverIds)
        for commonId in commonIds {
            guard let localAnnotation = localAnnotationsMap[commonId],
                  let serverAnnotation = serverAnnotationsMap[commonId] else {
                continue
            }

            if let localDeletedAt = localAnnotation.deletedAt, !serverAnnotation.isDeleted {
                if serverAnnotation.wasUpdated(after: localDeletedAt) {
                    resolution.localUpdate.append(serverAnnotation)
                    resolution.models.append(serverAnnotation)
                } else {
                    resolution.serverDelete.append(localAnnotation)
                }
            } else if let serverDeletedAt = serverAnnotation.deletedAt, !localAnnotation.isDeleted {
                if localAnnotation.wasUpdated(after: serverDeletedAt) {
                    resolution.serverUpdate.append(localAnnotation)
                    resolution.models.append(localAnnotation)
                } else {
                    resolution.localDelete.append(serverAnnotation)
                }
            } else if localAnnotation.isDeleted && serverAnnotation.isDeleted {
                resolution.models.append(serverAnnotation)
            } else if localAnnotation == serverAnnotation {
                resolution.localUpdate.append(serverAnnotation)
                resolution.models.append(serverAnnotation)
            } else {
                // TODO: Create deep copies of relations
                let modifiedLocalAnnotation = Annotation(origin: localAnnotation.origin,
                                                         width: localAnnotation.width,
                                                         parts: localAnnotation.parts,
                                                         selectionBox: localAnnotation.selectionBox,
                                                         ownerId: localAnnotation.ownerId,
                                                         documentId: localAnnotation.documentId,
                                                         id: UUID(),
                                                         createdAt: localAnnotation.createdAt,
                                                         updatedAt: localAnnotation.updatedAt,
                                                         deletedAt: localAnnotation.deletedAt)
                resolution.models.append(modifiedLocalAnnotation)
                resolution.models.append(serverAnnotation)
            }
        }

        return resolution
    }
}
