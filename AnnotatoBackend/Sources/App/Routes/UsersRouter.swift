import Vapor

func usersRouter(users: RoutesBuilder) {
    users.post(use: UsersController.create)
}
