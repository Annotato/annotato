import UIKit
import AnnotatoSharedLibrary

class ChangeOwnerListCellView: UITableViewCell {
    var user: UserViewModel?
    private var radioButton = RadioButton()

    func initializeSubviews() {
        initializeNameLabel()
        initializeRadioButton()
    }

    private func initializeNameLabel() {
        let label = UILabel()
        label.text = user?.displayName

        addSubview(label)

        label.translatesAutoresizingMaskIntoConstraints = false
        label.widthAnchor.constraint(equalTo: self.widthAnchor).isActive = true
        label.centerYAnchor.constraint(equalTo: self.centerYAnchor).isActive = true
        label.leftAnchor.constraint(equalTo: self.leftAnchor, constant: 5.0).isActive = true
    }

    private func initializeRadioButton() {
        radioButton = RadioButton()
        radioButton.isSelected = isSelected

        addSubview(radioButton)

        let buttonHeight = self.frame.height * 0.95
        radioButton.translatesAutoresizingMaskIntoConstraints = false
        radioButton.heightAnchor.constraint(equalToConstant: buttonHeight).isActive = true
        radioButton.widthAnchor.constraint(equalTo: radioButton.heightAnchor).isActive = true
        radioButton.rightAnchor.constraint(equalTo: self.rightAnchor, constant: 5.0).isActive = true
        radioButton.centerYAnchor.constraint(equalTo: self.centerYAnchor).isActive = true
    }

    func didTap() {
        isSelected.toggle()
        radioButton.isSelected = isSelected
    }

    func unselect() {
        isSelected = false
        radioButton.isSelected = isSelected
    }
}
