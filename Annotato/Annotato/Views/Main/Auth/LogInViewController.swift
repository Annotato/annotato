import UIKit

class LogInViewController: UIViewController, Navigable {

    override func viewDidLoad() {
        super.viewDidLoad()

        initializeSubviews()
    }

    private func initializeSubviews() {
        initializeLoginButton()
    }

    private func initializeLoginButton() {
        let loginButton = FilledButton(
            title: "Log In",
            frame: CGRect(x: .zero, y: .zero, width: 240, height: 40)
        )

        loginButton.center = view.center
        loginButton.addTarget(self, action: #selector(didTapLoginButton), for: .touchUpInside)

        view.addSubview(loginButton)
    }

    @objc
    private func didTapLoginButton() {
        goToDocumentList()
    }
}
