import Vapor

func webSocketRouter(ws: RoutesBuilder) {
    let webSocketController = WebSocketController()

    ws.group(":userId") { user in
        user.webSocket(maxFrameSize: WebSocketMaxFrameSize(integerLiteral: 1 << 31),
                       onUpgrade: webSocketController.handleIncomingConnection)
    }
}
