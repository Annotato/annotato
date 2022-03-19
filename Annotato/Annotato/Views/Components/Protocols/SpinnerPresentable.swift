import UIKit

protocol SpinnerPresentable where Self: UIViewController {
    var spinner: UIActivityIndicatorView { get }

    func initializeSpinner()
    func startSpinner()
    func stopSpinner()
}

extension SpinnerPresentable {
    func initializeSpinner() {
        view.addSubview(spinner)

        spinner.translatesAutoresizingMaskIntoConstraints = false
        spinner.centerXAnchor.constraint(equalTo: view.centerXAnchor).isActive = true
        spinner.centerYAnchor.constraint(equalTo: view.centerYAnchor).isActive = true
    }

    func startSpinner() {
        spinner.startAnimating()
    }

    func stopSpinner() {
        spinner.stopAnimating()
    }
}
