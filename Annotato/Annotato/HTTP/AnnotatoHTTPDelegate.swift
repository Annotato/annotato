import Foundation

protocol AnnotatoHTTPDelegate: AnyObject {
    func requestDidFail(_ error: Error)

    func requestDidSucceed(data: Data?)
}
