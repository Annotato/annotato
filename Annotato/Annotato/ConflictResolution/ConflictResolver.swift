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

            if localModel.isDeleted && !serverModel.isDeleted {
                handleDeletedOnlyOnLocal(localModel: localModel, serverModel: serverModel,
                                         resolution: &resolution)
            } else if !localModel.isDeleted && serverModel.isDeleted {
                handleDeletedOnlyOnServer(localModel: localModel, serverModel: serverModel,
                                          resolution: &resolution)
            } else if localModel.isDeleted && serverModel.isDeleted {
                handleDeletedOnBothLocalAndServer(localModel: localModel, serverModel: serverModel,
                                                  resolution: &resolution)
            } else if localModel == serverModel {
                handleEqualLocalAndServer(localModel: localModel, serverModel: serverModel,
                                          resolution: &resolution)
            } else {
                handleConflictingLocalAndServer(localModel: localModel, serverModel: serverModel,
                                                resolution: &resolution)
            }
        }
    }

    private func handleDeletedOnlyOnLocal(localModel: Model, serverModel: Model,
                                          resolution: inout ConflictResolution<Model>) {
        guard localModel.isDeleted && !serverModel.isDeleted else {
            return
        }

        guard let lastOnline = NetworkMonitor.shared.getLastOnlineDatetime(),
                serverModel.wasUpdated(after: lastOnline) else {
            // Server version was not updated after local deletion, can safely delete on server
            resolution.serverDelete.append(localModel)

            resolution.nonConflictingModels.append(localModel)
            return
        }

        // Server version was updated after local deletion, restore and update local version
        resolution.localUpdate.append(serverModel)

        resolution.nonConflictingModels.append(serverModel)
    }

    private func handleDeletedOnlyOnServer(localModel: Model, serverModel: Model,
                                           resolution: inout ConflictResolution<Model>) {
        guard let serverDeletedAt = serverModel.deletedAt, !localModel.isDeleted else {
            return
        }

        guard localModel.wasUpdated(after: serverDeletedAt) else {
            // Local version was not updated after server deletion, can safely delete locally
            resolution.localDelete.append(serverModel)

            resolution.nonConflictingModels.append(serverModel)
            return
        }

        // Local version was updated after server deletion, restore and update server version
        resolution.serverUpdate.append(localModel)

        resolution.nonConflictingModels.append(localModel)
    }

    private func handleDeletedOnBothLocalAndServer(localModel: Model, serverModel: Model,
                                                   resolution: inout ConflictResolution<Model>) {
        guard localModel.isDeleted && serverModel.isDeleted else {
            return
        }

        // Persist server timestamps
        resolution.localUpdate.append(serverModel)

        resolution.nonConflictingModels.append(serverModel)
    }

    private func handleEqualLocalAndServer(localModel: Model, serverModel: Model,
                                           resolution: inout ConflictResolution<Model>) {
        guard localModel == serverModel else {
            return
        }

        // Persist server timestamps
        resolution.localUpdate.append(serverModel)

        resolution.nonConflictingModels.append(serverModel)
    }

    private func handleConflictingLocalAndServer(localModel: Model, serverModel: Model,
                                                 resolution: inout ConflictResolution<Model>) {
        guard localModel != serverModel else {
            return
        }

        resolution.conflictingModels.append((localModel, serverModel))
    }
}
