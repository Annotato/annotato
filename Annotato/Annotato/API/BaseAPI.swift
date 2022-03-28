struct BaseAPI {
    // HTTP
    private static let localApiEndpoint = "http://127.0.0.1:8080"
    private static let remoteApiEndpoint = "http://178.128.111.22:80"

    // TODO: CHANGE TO REMOTE ENDPOINT BEFORE MERGE
    static let baseAPIUrl = localApiEndpoint

    // WebSocket
    private static let localApiWsEnpoint = "ws://127.0.0.1:8080"
    private static let remoteApiWsEnpoint = "ws://178.128.111.22:80"

    // TODO: CHANGE TO REMOTE ENDPOINT BEFORE MERGE
    static let baseWsAPIUrl = localApiWsEnpoint
}
