import UIKit

protocol AlertPresentable where Self: UIViewController {
    func presentTimedAlert(title: String, message: String)
    func presentErrorAlert(errorMessage: String)
    func presentSuccessAlert(successMessage: String)
    func presentWarningAlert(warningMessage: String, confirmHandler: @escaping () -> Void)
}

extension AlertPresentable {
    func presentTimedAlert(title: String, message: String) {
        let alertController = UIAlertController(title: title, message: message, preferredStyle: .alert)

        let displayDuration = DispatchTime.now() + 1
        DispatchQueue.main.asyncAfter(deadline: displayDuration) {
            alertController.dismiss(animated: true, completion: nil)
        }

        present(alertController, animated: true)
    }

    func presentErrorAlert(errorMessage: String) {
        let alertController = UIAlertController(
            title: "Error",
            message: errorMessage,
            preferredStyle: .alert)
        let confirmAction = UIAlertAction(title: "Okay", style: .default)
        alertController.addAction(confirmAction)
        present(alertController, animated: true)
    }

    func presentSuccessAlert(successMessage: String) {
        let alertController = UIAlertController(
            title: "",
            message: successMessage,
            preferredStyle: .alert)

        let displayDuration = DispatchTime.now() + 1
        DispatchQueue.main.asyncAfter(deadline: displayDuration) {
            alertController.dismiss(animated: true, completion: nil)
        }

        present(alertController, animated: true)
    }

    func presentWarningAlert(warningMessage: String, confirmHandler: @escaping () -> Void) {
        let alertController = UIAlertController(
            title: "Are you sure?",
            message: warningMessage,
            preferredStyle: .alert)

        let confirmAction = UIAlertAction(
            title: "Yes",
            style: .destructive,
            handler: { _ in confirmHandler() })

        let cancelAction = UIAlertAction(title: "No", style: .cancel)

        alertController.addAction(confirmAction)
        alertController.addAction(cancelAction)

        present(alertController, animated: true)
    }
}
