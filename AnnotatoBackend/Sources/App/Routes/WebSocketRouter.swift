import Vapor

func webSocketRouter(ws: RoutesBuilder) {
    ws.group(":userId") { user in
        user.webSocket(maxFrameSize: WebSocketMaxFrameSize(integerLiteral: 1 << 31),
                       onUpgrade: WebSocketController.handleIncomingConnection)
    }
}
