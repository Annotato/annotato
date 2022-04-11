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
                resolution.conflictingModels.append((localModel, serverModel))
            }
        }
    }
}
