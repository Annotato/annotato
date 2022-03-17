import Foundation

protocol AnnotatoStorageDelegate: AnyObject {
    func uploadDidFail(_ error: Error)
    func deleteDidFail(_ error: Error)
    func uploadDidSucceed()
    func deleteDidSucceed()
}
