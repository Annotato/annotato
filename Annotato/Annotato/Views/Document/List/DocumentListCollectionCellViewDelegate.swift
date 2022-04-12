protocol DocumentListCollectionCellViewDelegate: AnyObject {
    func didSelectCellView(document: DocumentListCellViewModel)
    func didLongPressCellView()
    func didTapDeleteButton(document: DocumentListCellViewModel)
}
