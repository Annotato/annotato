import AnnotatoSharedLibrary

class DocumentConflictResolver: ConflictResolver<Document> {
    override func handleExclusiveToServer(serverModelId: Document.ID, resolution: inout ConflictResolution<Document>) {
        guard let serverModel = serverModelsMap[serverModelId] else {
            return
        }
        resolution.serverDelete.append(serverModel)
        resolution.nonConflictingModels.append(serverModel)
    }
}
