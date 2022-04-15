import UIKit

class DocumentListCollectionView: UICollectionView {
    let cellId = "DocumentListCollectionCell"
    private var documents: [DocumentListCellPresenter]
    private weak var documentListCollectionCellViewDelegate: DocumentListCollectionCellViewDelegate?
    private(set) var isInDeleteMode: Bool

    @available(*, unavailable)
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    required init(
        documents: [DocumentListCellPresenter],
        frame: CGRect,
        documentListCollectionCellViewDelegate: DocumentListCollectionCellViewDelegate,
        initializeInDeleteMode: Bool
    ) {
        self.documents = documents
        self.documentListCollectionCellViewDelegate = documentListCollectionCellViewDelegate
        self.isInDeleteMode = initializeInDeleteMode
        let layout = UICollectionViewFlowLayout()
        layout.itemSize = CGSize(width: 180, height: 220)

        super.init(frame: frame, collectionViewLayout: layout)
        dataSource = self
        register(DocumentListCollectionCellView.self, forCellWithReuseIdentifier: cellId)
    }

    func enterDeleteMode() {
        guard let visibleCells = visibleCells as? [DocumentListCollectionCellView] else {
            return
        }

        isInDeleteMode = true

        for cell in visibleCells {
            cell.enterDeleteMode()
        }
    }

    func exitDeleteMode() {
        guard let visibleCells = visibleCells as? [DocumentListCollectionCellView] else {
            return
        }

        isInDeleteMode = false

        for cell in visibleCells {
            cell.exitDeleteMode()
        }
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
        cell.actionDelegate = documentListCollectionCellViewDelegate
        cell.initializeSubviews(inDeleteMode: isInDeleteMode)

        return cell
    }
}
