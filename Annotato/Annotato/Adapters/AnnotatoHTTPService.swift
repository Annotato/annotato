import Foundation

protocol AnnotatoHTTPService {
    func get(url: String, params: [String: String]) async throws -> Data

    func get(url: String) async throws -> Data

    func post(url: String, data: Data) async throws -> Data

    func put(url: String, data: Data) async throws -> Data

    func delete(url: String) async throws -> Data
}
