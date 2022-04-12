import AnnotatoSharedLibrary

class UserViewModel {
    let model: AnnotatoUser

    var displayName: String {
        model.displayName
    }

    init(model: AnnotatoUser) {
        self.model = model
    }
}
