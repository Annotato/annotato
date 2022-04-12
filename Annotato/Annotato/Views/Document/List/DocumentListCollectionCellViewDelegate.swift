protocol DocumentListCollectionCellViewDelegate: AnyObject {
    func didSelectCellView(document: DocumentListCellViewModel)
    func didLongPressCellView()
}
