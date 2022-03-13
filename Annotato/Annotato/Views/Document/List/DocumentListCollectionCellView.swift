import UIKit

class DocumentListCollectionCellView: UICollectionViewCell {
    var document: DocumentListViewModel?
    let nameLabelHeight = 30.0

    @available(*, unavailable)
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override init(frame: CGRect) {
        super.init(frame: frame)
    }

    func initializeSubviews() {
        initializeIconImageView()
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

    private func initializeNameLabel() {
        guard let document = document else {
            return
        }

        let label = UILabel()
        label.text = document.name
        label.textAlignment = .center

        addSubview(label)

        label.translatesAutoresizingMaskIntoConstraints = false
        label.widthAnchor.constraint(equalToConstant: self.frame.width).isActive = true
        label.heightAnchor.constraint(equalToConstant: nameLabelHeight).isActive = true
        label.bottomAnchor.constraint(equalTo: self.bottomAnchor).isActive = true
        label.centerXAnchor.constraint(equalTo: self.centerXAnchor).isActive = true
    }
}
