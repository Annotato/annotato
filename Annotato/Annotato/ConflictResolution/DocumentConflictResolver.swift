import AnnotatoSharedLibrary

class DocumentConflictResolver: ConflictResolver<Document> {
    override func handleExclusiveToServer(serverModelId: Document.ID, resolution: inout ConflictResolution<Document>) {
        let serverModel = serverModelsMap[serverModelId]
        resolution.serverDelete.appendIfNotNil(serverModel)
        resolution.nonConflictingModels.appendIfNotNil(serverModel)
    }
}
