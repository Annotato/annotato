import Vapor

func webSocketRouter(ws: RoutesBuilder) {
    ws.group(":userId") { user in
        user.webSocket(onUpgrade: WebSocketController.handleIncomingConnection)
    }
}
