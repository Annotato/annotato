protocol DocumentListCollectionCellViewDelegate: AnyObject {
    func didSelectCellView(document: DocumentListCellPresenter)
    func didLongPressCellView()
    func didTapDeleteForEveryoneButton(document: DocumentListCellPresenter)
    func didTapDeleteAsNonOwner(document: DocumentListCellPresenter)
    func didTapChangeOwnerButton(document: DocumentListCellPresenter)
}
