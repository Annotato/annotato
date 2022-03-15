import Foundation

protocol AnnotatoHTTPService {
    func get(url: String, params: [String:String]) throws -> AnnotatoHTTPResponse

    func post(url: String, data: Data) throws -> AnnotatoHTTPResponse

    func put(url: String, data: Data) throws -> AnnotatoHTTPResponse

    func delete(url: String) throws -> AnnotatoHTTPResponse
}
