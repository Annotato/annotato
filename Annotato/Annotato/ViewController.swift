//
//  ViewController.swift
//  Annotato
//
//  Created by Sivayogasubramanian on 10/3/22.
//

import UIKit

class ViewController: UIViewController {

    // Storyboard UI Elements
    @IBOutlet private var formSegmentedControl: UISegmentedControl!
    @IBOutlet private var emailTextField: UITextField!
    @IBOutlet private var passwordTextField: UITextField!
    @IBOutlet private var submitButton: UIButton!

    @IBOutlet private var heightConstraint: NSLayoutConstraint!
    @IBOutlet private var displayNameContainer: UIView!

    private enum Segment: Int {
        case signIn
        case signUp
    }

    let signInButtonText = "Sign In"
    let signUpButtonText = "Sign Up"

    override func viewDidLoad() {
        super.viewDidLoad()
        displayNameContainer.isHidden = true
        heightConstraint.constant = 50
    }

    private func updateFormViews() {
        let segment = Segment(rawValue: formSegmentedControl.selectedSegmentIndex)
        switch segment {
        case .signIn:
            displayNameContainer.isHidden = true
            heightConstraint.constant = 50
            submitButton.setTitle(signInButtonText, for: .normal)
        case .signUp:
            displayNameContainer.isHidden = false
            heightConstraint.constant = 30
            submitButton.setTitle(signUpButtonText, for: .normal)
        default:
            fatalError("Invalid Segment")
        }
    }

    @IBAction private func onFormActionChanged(_ sender: UISegmentedControl) {
        updateFormViews()
    }

    @IBAction private func onSubmitButtonTapped(_ sender: UIButton) {
        let segment = Segment(rawValue: formSegmentedControl.selectedSegmentIndex)
        switch segment {
        case .signIn:
            print("Sign In button tapped")
        case .signUp:
            print("Sign Up button tapped")
        default:
            fatalError("Invalid Segment")
        }
    }
}
