import UIKit

class LogInViewController: UIViewController {
    override func viewDidLoad() {
        super.viewDidLoad()

        initializeSubviews()
    }

    private func initializeSubviews() {
        let loginButton = makeLoginButton()
        view.addSubview(loginButton)
    }

    private func makeLoginButton() -> UIButton {
        let loginButton = FilledButton(
            title: "Log In",
            frame: CGRect(x: .zero, y: .zero, width: 240, height: 40)
        )

        loginButton.center = view.center
        return loginButton
    }
}
