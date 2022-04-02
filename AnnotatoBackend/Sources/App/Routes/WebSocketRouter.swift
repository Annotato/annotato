import Vapor

func webSocketRouter(ws: RoutesBuilder) {
    ws.group(":userId") { user in
        user.webSocket(maxFrameSize: WebSocketMaxFrameSize(integerLiteral: 1 << 32),
                       onUpgrade: WebSocketController.handleIncomingConnection)
    }
}
