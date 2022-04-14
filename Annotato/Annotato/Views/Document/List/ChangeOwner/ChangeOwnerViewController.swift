import UIKit
import Combine

class ChangeOwnerViewController: UIViewController, AlertPresentable, Navigable {
    var users: [UserViewModel]?
    var document: DocumentViewModel?
    private var titleLabel = UILabel()
    private var confirmButton = UIButton()
    private var listView = ChangeOwnerListView(frame: .zero, users: [])
    private var cancellables: Set<AnyCancellable> = []

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)

        initializeTitle()
        initializeConfirmButton()
        initializeUsersListView()
        setUpSubscribers()
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
        confirmButton.addTarget(self, action: #selector(didTapConfirmButton), for: .touchUpInside)

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

        listView = ChangeOwnerListView(frame: .zero, users: users)

        view.addSubview(listView)

        listView.translatesAutoresizingMaskIntoConstraints = false
        listView.widthAnchor.constraint(equalToConstant: frame.width * 0.9).isActive = true
        listView.heightAnchor.constraint(equalToConstant: frame.height * 0.9).isActive = true
        listView.topAnchor.constraint(equalTo: titleLabel.bottomAnchor).isActive = true
        listView.bottomAnchor.constraint(equalTo: confirmButton.topAnchor, constant: -10.0).isActive = true
        listView.centerXAnchor.constraint(equalTo: margins.centerXAnchor).isActive = true
    }

    @objc
    private func didTapConfirmButton() {
        guard let selectedNewOwner = listView.selectedUser else {
            presentErrorAlert(errorMessage: "Please select a new owner")
            return
        }

        document?.updateOwner(newOwnerId: selectedNewOwner.id)
    }

    private func receiveUpdateDocumentOwner(isSuccess: Bool) {
        if isSuccess {
            self.goBack()
        } else {
            presentErrorAlert(errorMessage: "There was an error updating the owner, please try again later")
        }
    }

    private func setUpSubscribers() {
        document?.$updateOwnerIsSuccess.sink(receiveValue: { [weak self] updateOwnerIsSuccess in
            guard let updateOwnerIsSuccess = updateOwnerIsSuccess else {
                return
            }

            DispatchQueue.main.async {
                self?.receiveUpdateDocumentOwner(isSuccess: updateOwnerIsSuccess)
            }
        }).store(in: &cancellables)
    }
}
