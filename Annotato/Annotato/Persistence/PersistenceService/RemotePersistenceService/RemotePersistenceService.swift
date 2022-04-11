struct RemotePersistenceService {
    private static let shouldUseLocalEndpoint = false

    // HTTP
    private static let localApiEndpoint = "http://127.0.0.1:8080"
    private static let remoteApiEndpoint = "http://178.128.111.22:80"

    static let baseAPIUrl = shouldUseLocalEndpoint ? localApiEndpoint : remoteApiEndpoint

    // WebSocket
    private static let localApiWsEndpoint = "ws://127.0.0.1:8080"
    private static let remoteApiWsEndpoint = "ws://178.128.111.22:80"

    static let baseWsAPIUrl = shouldUseLocalEndpoint ? localApiWsEndpoint : remoteApiWsEndpoint

    static func generateWebSocketUrlString(userId: String) -> String {
        "\(Self.baseWsAPIUrl)/ws/\(userId)"
    }
}

extension RemotePersistenceService {
    var documents: DocumentsRemotePersistence {
        RemoteDocumentsPersistence()
    }

    var annotations: AnnotationsRemotePersistence {
        RemoteAnnotationsPersistence()
    }

    var documentShares: DocumentSharesRemotePersistence {
        RemoteDocumentSharesPersistence()
    }

    var users: UsersPersistence {
        RemoteUsersPersistence()
    }
}
