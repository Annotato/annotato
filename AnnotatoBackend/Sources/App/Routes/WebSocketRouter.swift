import Vapor

func webSocketRouter(ws: RoutesBuilder) {
    ws.group(":id") { user in
        user.webSocket(onUpgrade: WebSocketController.handleIncomingConnection)
    }
}
