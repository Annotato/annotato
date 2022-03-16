import Foundation

protocol AnnotatoStorageDelegate: AnyObject {
    func uploadDidFail(_ error: Error)
    func uploadDidSucceed(_ url: URL)
}
