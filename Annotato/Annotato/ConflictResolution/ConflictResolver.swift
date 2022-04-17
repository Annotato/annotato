import AnnotatoSharedLibrary

class ConflictResolver<Model: ConflictResolvable> {
    let localModels: [Model]
    let serverModels: [Model]

    init(localModels: [Model], serverModels: [Model]) {
        self.localModels = localModels
        self.serverModels = serverModels
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

    func resolve() -> ConflictResolution<Model> {
        var resolution = ConflictResolution<Model>()
        for localId in localIds where !serverIds.contains(localId) {
            guard let localModel = localModelsMap[localId] else {
                continue
            }
            handleExclusiveToLocal(localModel: localModel, resolution: &resolution)
        }

        for serverId in serverIds where !localIds.contains(serverId) {
            guard let serverModel = serverModelsMap[serverId] else {
                continue
            }
            handleExclusiveToServer(serverModel: serverModel, resolution: &resolution)
        }

        for commonId in localIds.intersection(serverIds) {
            guard let localModel = localModelsMap[commonId],
                  let serverModel = serverModelsMap[commonId] else {
                continue
            }
            handleCommonToLocalAndServer(localModel: localModel, serverModel: serverModel, resolution: &resolution)
        }

        return resolution
    }

    func handleExclusiveToLocal(localModel: Model, resolution: inout ConflictResolution<Model>) {
        resolution.serverCreate.append(localModel)
        resolution.nonConflictingModels.append(localModel)
    }

    func handleExclusiveToServer(serverModel: Model, resolution: inout ConflictResolution<Model>) {
        resolution.localCreate.append(serverModel)
        resolution.nonConflictingModels.append(serverModel)
    }

    func handleCommonToLocalAndServer(localModel: Model, serverModel: Model,
                                      resolution: inout ConflictResolution<Model>) {
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
        guard localModel.isDeleted && !serverModel.isDeleted else {
            return
        }

        guard let lastOnline = NetworkMonitor.shared.getLastOnlineDatetime(),
                serverModel.wasUpdated(after: lastOnline) else {
            // Server version was not updated after going offline, can safely delete on server
            resolution.serverDelete.append(localModel)

            resolution.nonConflictingModels.append(localModel)
            return
        }

        // Server version was updated after going offline, restore and update local version
        resolution.localUpdate.append(serverModel)

        resolution.nonConflictingModels.append(serverModel)
    }

    private func handleDeletedOnlyOnServer(localModel: Model, serverModel: Model,
                                           resolution: inout ConflictResolution<Model>) {
        guard serverModel.isDeleted && !localModel.isDeleted else {
            return
        }

        guard let lastOnline = NetworkMonitor.shared.getLastOnlineDatetime(),
              localModel.wasUpdated(after: lastOnline) else {
            // Local version was not updated after going offline, can safely delete locally
            resolution.localDelete.append(serverModel)

            resolution.nonConflictingModels.append(serverModel)
            return
        }

        // Local version was updated after going offline, restore and update server version
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

        guard let lastOnline = NetworkMonitor.shared.getLastOnlineDatetime(),
              localModel.wasUpdated(after: lastOnline) else {
            // Local version was not updated after going offline, safely accept server version
            resolution.localUpdate.append(serverModel)

            resolution.nonConflictingModels.append(serverModel)
            return
        }

        guard let lastOnline = NetworkMonitor.shared.getLastOnlineDatetime(),
              serverModel.wasUpdated(after: lastOnline) else {
            resolution.serverUpdate.append(localModel)

            resolution.nonConflictingModels.append(localModel)
            return
        }

        resolution.conflictingModels.append((localModel, serverModel))
    }
}
