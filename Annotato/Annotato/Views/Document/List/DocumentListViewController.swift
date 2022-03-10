import UIKit

class DocumentListViewController: UIViewController {
    private var documents = [
        DocumentListViewModel(name: "Test A"),
        DocumentListViewModel(name: "Test B"),
        DocumentListViewModel(name: "Test C"),
        DocumentListViewModel(name: "Test D"),
        DocumentListViewModel(name: "Test E")
    ]

    override func viewDidLoad() {
        super.viewDidLoad()

        initializeSubviews()
    }

    private func initializeSubviews() {
        initializeDocumentsCollectionView()
    }

    private func initializeDocumentsCollectionView() {
        let collectionView = DocumentListCollectionView(documents: documents, frame: .zero)

        view.addSubview(collectionView)

        collectionView.translatesAutoresizingMaskIntoConstraints = false
        collectionView.widthAnchor.constraint(equalToConstant: self.view.frame.width * 0.9).isActive = true
        collectionView.heightAnchor.constraint(equalToConstant: self.view.frame.height * 0.9).isActive = true
        collectionView.centerXAnchor.constraint(equalTo: self.view.centerXAnchor).isActive = true
    }
}
