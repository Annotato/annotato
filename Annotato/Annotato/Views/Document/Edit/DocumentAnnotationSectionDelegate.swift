protocol DocumentAnnotationSectionDelegate: AnyObject {
    func didSelect(section: DocumentAnnotationSectionView)
    func didBecomeEmpty(section: DocumentAnnotationSectionView)
    func frameDidChange()
    func didBeginEditing(annotationType: AnnotationType)
}
