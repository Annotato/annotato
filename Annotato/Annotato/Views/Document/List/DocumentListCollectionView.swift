import UIKit

class DocumentListCollectionView: UICollectionView {
    let cellId = "DocumentListCollectionCell"
    private var documents: [DocumentListViewModel]

    @available(*, unavailable)
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    required init(documents: [DocumentListViewModel], frame: CGRect) {
        self.documents = documents

        let layout = UICollectionViewFlowLayout()
        layout.itemSize = CGSize(width: 180, height: 220)

        super.init(frame: frame, collectionViewLayout: layout)
        dataSource = self
        register(DocumentListCollectionCellView.self, forCellWithReuseIdentifier: cellId)
    }
}

extension DocumentListCollectionView: UICollectionViewDataSource {
    func collectionView(
        _ collectionView: UICollectionView, numberOfItemsInSection section: Int
    ) -> Int {
        documents.count
    }

    func collectionView(
        _ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath
    ) -> UICollectionViewCell {
        guard let cell = dequeueReusableCell(
            withReuseIdentifier: cellId, for: indexPath
        ) as? DocumentListCollectionCellView else {
            fatalError("unable to dequeue DocumentListCollectionView cell")
        }

        cell.document = documents[indexPath.row]
        cell.initializeSubviews()

        return cell
    }
}