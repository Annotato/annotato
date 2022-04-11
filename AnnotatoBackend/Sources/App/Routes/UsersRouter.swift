import Vapor

func usersRouter(users: RoutesBuilder) {
    let usersController = UsersController()

    users.get("sharing", use: usersController.listUsersSharingDocument)

    users.post(use: usersController.create)

    users.group(":id") { user in
        user.get(use: usersController.read)
    }
}
