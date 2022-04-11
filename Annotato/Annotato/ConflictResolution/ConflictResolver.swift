import Foundation
import AnnotatoSharedLibrary

struct ConflictResolver<Model: ConflictResolvable> {
    let localModels: [Model]
    let serverModels: [Model]

    func resolve() -> ConflictResolution<Model> {
        var resolution = ConflictResolution<Model>()
        handleExclusiveToLocal(resolution: &resolution)
        handleExclusiveToServer(resolution: &resolution)
        handleCommonToLocalAndServer(resolution: &resolution)

        return resolution
    }

    private var localIds: Set<Model.ID> {
        Set(localModels.map({ $0.id }))
    }

    private var serverIds: Set<Model.ID> {
        Set(serverModels.map({ $0.id }))
    }

    private var localModelsMap: [Model.ID: Model] {
        Dictionary(uniqueKeysWithValues: localModels.map({ ($0.id, $0) }))
    }

    private var serverModelsMap: [Model.ID: Model] {
        Dictionary(uniqueKeysWithValues: serverModels.map({ ($0.id, $0) }))
    }

    private func handleExclusiveToLocal(resolution: inout ConflictResolution<Model>) {
        for localId in localIds where !serverIds.contains(localId) {
            let localModel = localModelsMap[localId]
            resolution.serverCreate.appendIfNotNil(localModel)
            resolution.nonConflictingModels.appendIfNotNil(localModel)
        }
    }

    private func handleExclusiveToServer(resolution: inout ConflictResolution<Model>) {
        for serverId in serverIds where !localIds.contains(serverId) {
            let serverModel = serverModelsMap[serverId]
            resolution.localCreate.appendIfNotNil(serverModel)
            resolution.nonConflictingModels.appendIfNotNil(serverModel)
        }
    }

    private func handleCommonToLocalAndServer(resolution: inout ConflictResolution<Model>) {
        let commonIds = localIds.intersection(serverIds)
        for commonId in commonIds {
            guard let localModel = localModelsMap[commonId],
                  let serverModel = serverModelsMap[commonId] else {
                continue
            }

            if let localDeletedAt = localModel.deletedAt, !serverModel.isDeleted {
                if serverModel.wasUpdated(after: localDeletedAt) {
                    resolution.localUpdate.append(serverModel)
                    resolution.nonConflictingModels.append(serverModel)
                } else {
                    resolution.serverDelete.append(localModel)
                    resolution.nonConflictingModels.append(localModel)
                }
            } else if let serverDeletedAt = serverModel.deletedAt, !localModel.isDeleted {
                if localModel.wasUpdated(after: serverDeletedAt) {
                    resolution.serverUpdate.append(localModel)
                    resolution.nonConflictingModels.append(localModel)
                } else {
                    resolution.localDelete.append(serverModel)
                    resolution.nonConflictingModels.append(serverModel)
                }
            } else if localModel.isDeleted && serverModel.isDeleted {
                resolution.nonConflictingModels.append(serverModel)
            } else if localModel == serverModel {
                resolution.localUpdate.append(serverModel)
                resolution.nonConflictingModels.append(serverModel)
            } else {
                let modifiedLocalAnnotation = localModel.clone()
                resolution.conflictingModels.append((modifiedLocalAnnotation, serverModel))
            }
        }
    }
}

// extension Annotation: Identifiable { }
//
// struct AnnotationConflictResolver: ConflictResolver {
//    let localModels: [Annotation]
//    let serverModels: [Annotation]
//    var resolution: ConflictResolution<Annotation>
//
//    init(localAnnotations: [Annotation], serverAnnotations: [Annotation]) {
//        self.localModels = localAnnotations
//        self.serverModels = serverAnnotations
//        self.resolution = ConflictResolution()
//        resolve()
//    }
//
//    private var localAnnotationsMap: [UUID: Annotation] {
//        Dictionary(uniqueKeysWithValues: localModels.map({ ($0.id, $0) }))
//    }
//
//    private var serverAnnotationsMap: [UUID: Annotation] {
//        Dictionary(uniqueKeysWithValues: serverModels.map({ ($0.id, $0) }))
//    }
//
//    private var localIds: Set<UUID> {
//        Set(localModels.map({ $0.id }))
//    }
//
//    private var serverIds: Set<UUID> {
//        Set(serverModels.map({ $0.id }))
//    }
//
//    mutating func resolve() {
//        handleExclusiveToLocal()
//
//        handleExclusiveToServer()
//
//        handleCommonToLocalAndServer()
//    }
//
//    private mutating func handleExclusiveToLocal() {
//        for localId in localIds where !serverIds.contains(localId) {
//            let localAnnotation = localAnnotationsMap[localId]
//            resolution.serverCreate.appendIfNotNil(localAnnotation)
//            resolution.nonConflictingModels.appendIfNotNil(localAnnotation)
//        }
//    }
//
//    private mutating func handleExclusiveToServer() {
//        for serverId in serverIds where !localIds.contains(serverId) {
//            let serverAnnotation = serverAnnotationsMap[serverId]
//            resolution.localCreate.appendIfNotNil(serverAnnotation)
//            resolution.nonConflictingModels.appendIfNotNil(serverAnnotation)
//        }
//    }
//
//    private mutating func handleCommonToLocalAndServer() {
//        let commonIds = localIds.intersection(serverIds)
//        for commonId in commonIds {
//            guard let localAnnotation = localAnnotationsMap[commonId],
//                  let serverAnnotation = serverAnnotationsMap[commonId] else {
//                continue
//            }
//
//            if let localDeletedAt = localAnnotation.deletedAt, !serverAnnotation.isDeleted {
//                if serverAnnotation.wasUpdated(after: localDeletedAt) {
//                    resolution.localUpdate.append(serverAnnotation)
//                    resolution.nonConflictingModels.append(serverAnnotation)
//                } else {
//                    resolution.serverDelete.append(localAnnotation)
//                    resolution.nonConflictingModels.append(localAnnotation)
//                }
//            } else if let serverDeletedAt = serverAnnotation.deletedAt, !localAnnotation.isDeleted {
//                if localAnnotation.wasUpdated(after: serverDeletedAt) {
//                    resolution.serverUpdate.append(localAnnotation)
//                    resolution.nonConflictingModels.append(localAnnotation)
//                } else {
//                    resolution.localDelete.append(serverAnnotation)
//                    resolution.nonConflictingModels.append(serverAnnotation)
//                }
//            } else if localAnnotation.isDeleted && serverAnnotation.isDeleted {
//                resolution.nonConflictingModels.append(serverAnnotation)
//            } else if localAnnotation == serverAnnotation {
//                resolution.localUpdate.append(serverAnnotation)
//                resolution.nonConflictingModels.append(serverAnnotation)
//            } else {
//                let modifiedLocalAnnotation = localAnnotation.clone()
//                resolution.conflictingModels.append((modifiedLocalAnnotation, serverAnnotation))
//            }
//        }
//    }
// }
