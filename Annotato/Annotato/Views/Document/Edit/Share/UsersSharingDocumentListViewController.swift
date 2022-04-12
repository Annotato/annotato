import UIKit

class UsersSharingDocumentListViewController: UIViewController, AlertPresentable {
    var users: [UserViewModel]?
    var document: DocumentViewModel?
    private var titleLabel = UILabel()
    private var confirmButton = UIButton()

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)

        initializeTitle()
        initializeConfirmButton()
        initializeUsersListView()
    }

    private func initializeTitle() {
        titleLabel = UILabel()
        titleLabel.text = "Select a new owner"
        titleLabel.textAlignment = .center

        view.addSubview(titleLabel)

        let titleHeight = 50.0
        titleLabel.translatesAutoresizingMaskIntoConstraints = false
        titleLabel.heightAnchor.constraint(equalToConstant: titleHeight).isActive = true
        titleLabel.centerXAnchor.constraint(equalTo: margins.centerXAnchor).isActive = true
        titleLabel.topAnchor.constraint(equalTo: margins.topAnchor, constant: 10.0).isActive = true
    }

    private func initializeConfirmButton() {
        confirmButton = UIButton()
        confirmButton.setTitle("Confirm Selection", for: .normal)
        confirmButton.configuration = .filled()

        view.addSubview(confirmButton)

        let confirmButtonHeight = 50.0
        let confirmButtonWidth = confirmButtonHeight * 4
        confirmButton.translatesAutoresizingMaskIntoConstraints = false
        confirmButton.heightAnchor.constraint(equalToConstant: confirmButtonHeight).isActive = true
        confirmButton.widthAnchor.constraint(equalToConstant: confirmButtonWidth).isActive = true
        confirmButton.bottomAnchor.constraint(equalTo: margins.bottomAnchor, constant: -10.0).isActive = true
        confirmButton.centerXAnchor.constraint(equalTo: margins.centerXAnchor).isActive = true
    }

    private func initializeUsersListView() {
        guard let users = users else {
            presentErrorAlert(errorMessage: "Failed to load users")
            return
        }

        let listView = UsersSharingDocumentListView(frame: .zero, users: users)

        view.addSubview(listView)

        listView.translatesAutoresizingMaskIntoConstraints = false
        listView.widthAnchor.constraint(equalToConstant: frame.width * 0.9).isActive = true
        listView.heightAnchor.constraint(equalToConstant: frame.height * 0.9).isActive = true
        listView.topAnchor.constraint(equalTo: titleLabel.bottomAnchor).isActive = true
        listView.bottomAnchor.constraint(equalTo: confirmButton.topAnchor, constant: -10.0).isActive = true
        listView.centerXAnchor.constraint(equalTo: margins.centerXAnchor).isActive = true
    }
}
