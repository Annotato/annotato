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

        var nonConflictingModels: [Annotation] = []
        var conflictingModels: [(Annotation, Annotation)] = []
    }

    private let localAnnotations: [Annotation]
    private let serverAnnotations: [Annotation]
    private(set) var resolution: Resolution

    init(localAnnotations: [Annotation], serverAnnotations: [Annotation]) {
        self.localAnnotations = localAnnotations
        self.serverAnnotations = serverAnnotations
        self.resolution = Resolution()
        resolve()
    }

    private var localAnnotationsMap: [UUID: Annotation] {
        Dictionary(uniqueKeysWithValues: localAnnotations.map({ ($0.id, $0) }))
    }

    private var serverAnnotationsMap: [UUID: Annotation] {
        Dictionary(uniqueKeysWithValues: serverAnnotations.map({ ($0.id, $0) }))
    }

    private var localIds: Set<UUID> {
        Set(localAnnotations.map({ $0.id }))
    }

    private var serverIds: Set<UUID> {
        Set(serverAnnotations.map({ $0.id }))
    }

    mutating func resolve() {
        handleExclusiveToLocal()

        handleExclusiveToServer()

        handleCommonToLocalAndServer()
    }

    private mutating func handleExclusiveToLocal() {
        for localId in localIds where !serverIds.contains(localId) {
            let localAnnotation = localAnnotationsMap[localId]
            resolution.serverCreate.appendIfNotNil(localAnnotation)
            resolution.nonConflictingModels.appendIfNotNil(localAnnotation)
        }
    }

    private mutating func handleExclusiveToServer() {
        for serverId in serverIds where !localIds.contains(serverId) {
            let serverAnnotation = serverAnnotationsMap[serverId]
            resolution.localCreate.appendIfNotNil(serverAnnotation)
            resolution.nonConflictingModels.appendIfNotNil(serverAnnotation)
        }
    }

    private mutating func handleCommonToLocalAndServer() {
        let commonIds = localIds.intersection(serverIds)
        for commonId in commonIds {
            guard let localAnnotation = localAnnotationsMap[commonId],
                  let serverAnnotation = serverAnnotationsMap[commonId] else {
                continue
            }

            if let localDeletedAt = localAnnotation.deletedAt, !serverAnnotation.isDeleted {
                if serverAnnotation.wasUpdated(after: localDeletedAt) {
                    resolution.localUpdate.append(serverAnnotation)
                    resolution.nonConflictingModels.append(serverAnnotation)
                } else {
                    resolution.serverDelete.append(localAnnotation)
                    resolution.nonConflictingModels.append(localAnnotation)
                }
            } else if let serverDeletedAt = serverAnnotation.deletedAt, !localAnnotation.isDeleted {
                if localAnnotation.wasUpdated(after: serverDeletedAt) {
                    resolution.serverUpdate.append(localAnnotation)
                    resolution.nonConflictingModels.append(localAnnotation)
                } else {
                    resolution.localDelete.append(serverAnnotation)
                    resolution.nonConflictingModels.append(serverAnnotation)
                }
            } else if localAnnotation.isDeleted && serverAnnotation.isDeleted {
                resolution.nonConflictingModels.append(serverAnnotation)
            } else if localAnnotation == serverAnnotation {
                resolution.localUpdate.append(serverAnnotation)
                resolution.nonConflictingModels.append(serverAnnotation)
            } else {
                let modifiedLocalAnnotation = localAnnotation.clone()
                resolution.conflictingModels.append((modifiedLocalAnnotation, serverAnnotation))
            }
        }
    }
}
