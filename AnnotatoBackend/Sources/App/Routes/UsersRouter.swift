import Vapor

func usersRouter(users: RoutesBuilder) {
    let usersController = UsersController()

    users.get("sharing", use: usersController.listUsersSharingDocument)

    users.post(use: usersController.create)
}
