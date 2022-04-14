import AnnotatoSharedLibrary

class DocumentConflictResolver: ConflictResolver<Document> {
    override func handleExclusiveToServer(serverModel: Document, resolution: inout ConflictResolution<Document>) {
        resolution.serverDelete.append(serverModel)
    }
}
