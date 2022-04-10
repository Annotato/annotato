import Vapor

func usersRouter(users: RoutesBuilder) {
    users.get("sharing", use: UsersController.listUsersSharingDocument)

    users.post(use: UsersController.create)
}
