protocol DocumentListCollectionCellViewDelegate: AnyObject {
    func didSelectCellView(document: DocumentListCellViewModel)
    func didLongPressCellView()
    func didTapDeleteForEveryoneButton(document: DocumentListCellViewModel)
    func didTapDeleteAsNonOwner(document: DocumentListCellViewModel)
}
