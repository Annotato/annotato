import UIKit

class DocumentListCollectionCellView: UICollectionViewCell {
    var document: DocumentListCellViewModel?
    let nameLabelHeight = 30.0
    let deleteIconHeight = 50.0
    let shareIconWidth = 25.0
    private var deleteButton = UIButton()
    weak var actionDelegate: DocumentListCollectionCellViewDelegate?

    @available(*, unavailable)
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override init(frame: CGRect) {
        super.init(frame: frame)
    }

    func initializeSubviews() {
        addGestureRecognizers()
        initializeIconImageView()
        initializeDeleteIconButton()
        exitDeleteMode()

        if document?.isShared ?? false {
            initializeShareIconImageView()
        }
        initializeNameLabel()
    }

    private func initializeIconImageView() {
        let image = UIImage(named: ImageName.documentIcon.rawValue) ?? UIImage()
        let imageView = UIImageView(image: image)

        addSubview(imageView)

        imageView.translatesAutoresizingMaskIntoConstraints = false
        imageView.widthAnchor.constraint(equalToConstant: self.frame.width).isActive = true
        imageView.heightAnchor.constraint(equalToConstant: self.frame.height - nameLabelHeight).isActive = true
        imageView.topAnchor.constraint(equalTo: self.topAnchor).isActive = true
        imageView.centerXAnchor.constraint(equalTo: self.centerXAnchor).isActive = true
    }

    private func initializeDeleteIconButton() {
        let image = UIImage(named: ImageName.xIcon.rawValue) ?? UIImage()
        deleteButton = UIButton()
        deleteButton.setImage(image, for: .normal)
        deleteButton.tintColor = UIColor.red
        deleteButton.contentVerticalAlignment = .fill
        deleteButton.contentHorizontalAlignment = .fill

        addSubview(deleteButton)

        deleteButton.translatesAutoresizingMaskIntoConstraints = false
        deleteButton.heightAnchor.constraint(equalToConstant: deleteIconHeight).isActive = true
        deleteButton.widthAnchor.constraint(equalTo: deleteButton.heightAnchor).isActive = true
        deleteButton.rightAnchor.constraint(equalTo: self.rightAnchor).isActive = true
        deleteButton.topAnchor.constraint(equalTo: self.topAnchor).isActive = true
    }

    private func initializeShareIconImageView() {
        let image = UIImage(systemName: SystemImageName.people.rawValue) ?? UIImage()
        let imageView = UIImageView(image: image)
        imageView.tintColor = .systemGray

        addSubview(imageView)

        imageView.translatesAutoresizingMaskIntoConstraints = false
        imageView.widthAnchor.constraint(equalToConstant: shareIconWidth).isActive = true
        imageView.rightAnchor.constraint(equalTo: self.rightAnchor).isActive = true
        imageView.bottomAnchor.constraint(equalTo: self.bottomAnchor, constant: -5.0).isActive = true
    }

    private func initializeNameLabel() {
        guard let document = document else {
            return
        }

        let label = UILabel()
        label.text = document.name
        label.textAlignment = .center

        addSubview(label)

        label.translatesAutoresizingMaskIntoConstraints = false
        let width = document.isShared ? self.frame.width - shareIconWidth : self.frame.width
        label.widthAnchor.constraint(equalToConstant: width).isActive = true
        label.heightAnchor.constraint(equalToConstant: nameLabelHeight).isActive = true
        label.bottomAnchor.constraint(equalTo: self.bottomAnchor).isActive = true
        label.leftAnchor.constraint(equalTo: self.leftAnchor).isActive = true
    }

    private func addGestureRecognizers() {
        let tapGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(didTapOnCellView))
        addGestureRecognizer(tapGestureRecognizer)

        let longPressGestureRecognizer = UILongPressGestureRecognizer(
            target: self, action: #selector(didLongPressCellView))
        addGestureRecognizer(longPressGestureRecognizer)
    }

    @objc
    private func didTapOnCellView() {
        guard let document = document else {
            return
        }
        actionDelegate?.didSelectCellView(document: document)
    }

    @objc
    private func didLongPressCellView() {
        actionDelegate?.didLongPressCellView()
    }

    func enterDeleteMode() {
        deleteButton.isHidden = false
    }

    func exitDeleteMode() {
        deleteButton.isHidden = true
    }
}
