protocol DocumentAnnotationToolbarDelegate: AnyObject {
    func enterEditMode()
    func enterViewMode()
    func addOrReplaceSection(with annotationType: AnnotationType)
    func didDelete()
}
