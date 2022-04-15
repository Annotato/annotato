import AnnotatoSharedLibrary

class UserPresenter {
    let model: AnnotatoUser

    var id: String {
        model.id
    }

    var displayName: String {
        model.displayName
    }

    init(model: AnnotatoUser) {
        self.model = model
    }
}
