struct RemotePersistenceManager {
    // HTTP
    private static let localApiEndpoint = "http://127.0.0.1:8080"
    private static let remoteApiEndpoint = "http://178.128.111.22:80"

    static let baseAPIUrl = remoteApiEndpoint

    // WebSocket
    private static let localApiWsEndpoint = "ws://127.0.0.1:8080"
    private static let remoteApiWsEndpoint = "ws://178.128.111.22:80"

    static let baseWsAPIUrl = remoteApiWsEndpoint
}

extension RemotePersistenceManager: PersistenceManager {
    var documents: DocumentsPersistence {
        RemoteDocumentsPersistence()
    }

    var annotations: AnnotationsPersistence {
        RemoteAnnotationsPersistence()
    }

    var documentShares: DocumentSharesPersistence {
        RemoteDocumentSharesPersistence()
    }
}
