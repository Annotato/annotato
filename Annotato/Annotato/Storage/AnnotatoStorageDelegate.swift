protocol AnnotatoStorageDelegate: AnyObject {
    func uploadDidFail(_ error: Error)
    func downloadDidFail(_ error: Error)
    func uploadDidSucceed()
    func downloadDidSucceed()
}
