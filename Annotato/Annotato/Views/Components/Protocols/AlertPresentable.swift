import UIKit

protocol AlertPresentable where Self: UIViewController {
    func presentTimedAlert(title: String, message: String)
    func presentErrorAlert(errorMessage: String)
    func presentSuccessAlert(successMessage: String, completion: (() -> Void)?)
    func presentWarningAlert(alertTitle: String, warningMessage: String?, confirmHandler: @escaping () -> Void)
    func presentInfoAlert(alertTitle: String, message: String, confirmHandler: @escaping () -> Void)
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

    func presentSuccessAlert(successMessage: String, completion: (() -> Void)? = nil) {
        let alertController = UIAlertController(
            title: "",
            message: successMessage,
            preferredStyle: .alert)

        let displayDuration = DispatchTime.now() + 1
        DispatchQueue.main.asyncAfter(deadline: displayDuration) {
            alertController.dismiss(animated: true, completion: completion)
        }

        present(alertController, animated: true)
    }

    func presentWarningAlert(alertTitle: String = "Are you sure?", warningMessage: String? = nil,
                             confirmHandler: @escaping () -> Void) {
        let alertController = UIAlertController(
            title: alertTitle,
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

    func presentInfoAlert(alertTitle: String, message: String, confirmHandler: @escaping () -> Void) {
        let alertController = UIAlertController(
            title: alertTitle, message: message, preferredStyle: .alert)

        let confirmAction = UIAlertAction(
            title: "Ok",
            style: .default,
            handler: { _ in confirmHandler() })

        alertController.addAction(confirmAction)

        present(alertController, animated: true)
    }
}
