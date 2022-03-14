protocol DocumentAnnotationSectionDelegate: AnyObject {
    func didSelect(section: DocumentAnnotationSectionView)
    func didBecomeEmpty(section: DocumentAnnotationSectionView)
}
