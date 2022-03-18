import Foundation

struct URLSessionHTTPService: AnnotatoHTTPService {
    private let sharedSession = URLSession.shared

    func get(url: String, params: [String: String]) async throws -> Data {
        let urlWithParams = makeURLWithParams(url: url, params: params)
        guard let urlWithParams = urlWithParams else {
            throw AnnotatoHTTPError.invalidURL
        }

        var request = URLRequest(url: urlWithParams)
        request.httpMethod = AnnotatoHTTPMethod.get.rawValue

        let (data, _) = try await URLSession.shared.data(for: request)
        return data
    }

    func get(url: String) async throws -> Data {
        guard let url = URL(string: url) else {
            throw AnnotatoHTTPError.invalidURL
        }

        var request = URLRequest(url: url)
        request.httpMethod = AnnotatoHTTPMethod.get.rawValue

        let (data, _) = try await URLSession.shared.data(for: request)
        return data
    }

    func post(url: String, data: Data) async throws -> Data {
        guard let url = URL(string: url) else {
            throw AnnotatoHTTPError.invalidURL
        }

        var request = URLRequest(url: url)
        request.httpMethod = AnnotatoHTTPMethod.post.rawValue
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        request.httpBody = data

        let (data, _) = try await URLSession.shared.data(for: request)
        return data
    }

    func put(url: String, data: Data) async throws -> Data {
        guard let url = URL(string: url) else {
            throw AnnotatoHTTPError.invalidURL
        }

        var request = URLRequest(url: url)
        request.httpMethod = AnnotatoHTTPMethod.put.rawValue
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        request.httpBody = data

        let (data, _) = try await URLSession.shared.data(for: request)
        return data
    }

    func delete(url: String) async throws -> Data {
        guard let url = URL(string: url) else {
            throw AnnotatoHTTPError.invalidURL
        }

        var request = URLRequest(url: url)
        request.httpMethod = AnnotatoHTTPMethod.delete.rawValue

        let (data, _) = try await URLSession.shared.data(for: request)
        return data
    }

    private func makeURLWithParams(url: String, params: [String: String]) -> URL? {
        guard var urlComponents = URLComponents(string: url) else {
            return nil
        }

        let queryItems = params.map { key, value in
            URLQueryItem(name: key, value: value)
        }

        urlComponents.queryItems = queryItems

        return urlComponents.url
    }
}
