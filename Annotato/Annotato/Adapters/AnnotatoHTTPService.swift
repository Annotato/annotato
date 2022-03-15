import Foundation

protocol AnnotatoHTTPService {
    var delegate: AnnotatoHTTPDelegate? { get set }

    func get(url: String, params: [String: String])

    func post(url: String, data: Data)

    func put(url: String, data: Data)

    func delete(url: String)
}
