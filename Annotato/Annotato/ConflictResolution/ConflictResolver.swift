import AnnotatoSharedLibrary

class ConflictResolver<Model: ConflictResolvable> {
    let localModels: [Model]
    let serverModels: [Model]

    init(localModels: [Model], serverModels: [Model]) {
        self.localModels = localModels
        self.serverModels = serverModels
    }

    func resolve() -> ConflictResolution<Model> {
        var resolution = ConflictResolution<Model>()
        for localId in localIds where !serverIds.contains(localId) {
            handleExclusiveToLocal(localModelId: localId, resolution: &resolution)
        }

        for serverId in serverIds where !localIds.contains(serverId) {
            handleExclusiveToServer(serverModelId: serverId, resolution: &resolution)
        }

        for commonId in localIds.intersection(serverIds) {
            handleCommonToLocalAndServer(commonModelId: commonId, resolution: &resolution)
        }

        return resolution
    }

    private var localIds: Set<Model.ID> {
        Set(localModels.map({ $0.id }))
    }

    private var serverIds: Set<Model.ID> {
        Set(serverModels.map({ $0.id }))
    }

    var localModelsMap: [Model.ID: Model] {
        Dictionary(uniqueKeysWithValues: localModels.map({ ($0.id, $0) }))
    }

    var serverModelsMap: [Model.ID: Model] {
        Dictionary(uniqueKeysWithValues: serverModels.map({ ($0.id, $0) }))
    }

    private func handleExclusiveToLocal(localModelId: Model.ID, resolution: inout ConflictResolution<Model>) {
        let localModel = localModelsMap[localModelId]
        resolution.serverCreate.appendIfNotNil(localModel)
        resolution.nonConflictingModels.appendIfNotNil(localModel)
    }

    func handleExclusiveToServer(serverModelId: Model.ID, resolution: inout ConflictResolution<Model>) {
        let serverModel = serverModelsMap[serverModelId]
        resolution.localCreate.appendIfNotNil(serverModel)
        resolution.nonConflictingModels.appendIfNotNil(serverModel)
    }

    func handleCommonToLocalAndServer(commonModelId: Model.ID, resolution: inout ConflictResolution<Model>) {
        guard let localModel = localModelsMap[commonModelId],
              let serverModel = serverModelsMap[commonModelId] else {
            return
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

    private func handleDeletedOnlyOnLocal(localModel: Model, serverModel: Model,
                                          resolution: inout ConflictResolution<Model>) {
        guard let localDeletedAt = localModel.deletedAt, !serverModel.isDeleted else {
            return
        }

        guard serverModel.wasUpdated(after: localDeletedAt) else {
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
