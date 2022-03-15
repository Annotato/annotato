import Foundation

struct URLSessionHTTPService: AnnotatoHTTPService {
    private let sharedSession = URLSession.shared

    weak var delegate: AnnotatoHTTPDelegate?

    func get(url: String, params: [String: String]) {
        let urlWithParams = makeURLWithParams(url: url, params: params)
        guard let urlWithParams = urlWithParams else {
            delegate?.requestDidFail(AnnotatoHTTPError.invalidURL)
            return
        }

        var request = URLRequest(url: urlWithParams)
        request.httpMethod = "GET"

        let task = sharedSession.dataTask(with: request, completionHandler: makeCompletionHandler(httpMethod: "GET"))
        task.resume()
    }

    func post(url: String, data: Data) {
        guard let url = URL(string: url) else {
            delegate?.requestDidFail(AnnotatoHTTPError.invalidURL)
            return
        }

        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.httpBody = data

        let task = sharedSession.dataTask(with: request, completionHandler: makeCompletionHandler(httpMethod: "POST"))
        task.resume()
    }

    func put(url: String, data: Data) {
        guard let url = URL(string: url) else {
            delegate?.requestDidFail(AnnotatoHTTPError.invalidURL)
            return
        }

        var request = URLRequest(url: url)
        request.httpMethod = "PUT"
        request.httpBody = data

        let task = sharedSession.dataTask(with: request, completionHandler: makeCompletionHandler(httpMethod: "PUT"))
        task.resume()
    }

    func delete(url: String) {
        guard let url = URL(string: url) else {
            delegate?.requestDidFail(AnnotatoHTTPError.invalidURL)
            return
        }

        var request = URLRequest(url: url)
        request.httpMethod = "DELETE"

        let task = sharedSession.dataTask(with: request, completionHandler: makeCompletionHandler(httpMethod: "DELETE"))
        task.resume()
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

    private func makeCompletionHandler(httpMethod: String) -> (Data?, URLResponse?, Error?) -> Void {
        { data, response, error in
            if let error = error {
                AnnotatoLogger.error(
                    "Client error occurred during \(httpMethod) request: \(error.localizedDescription)",
                    context: "URLSessionHTTPService::\(httpMethod.lowercased())"
                )
                delegate?.requestDidFail(error)
                return
            }

            guard let httpResponse = response as? HTTPURLResponse,
                  (200...299).contains(httpResponse.statusCode) else {
                      AnnotatoLogger.error(
                          "Server error occurred during \(httpMethod) request",
                          context: "URLSessionHTTPService::\(httpMethod.lowercased())"
                      )
                      delegate?.requestDidFail(AnnotatoHTTPError.serverError)
                  }

            DispatchQueue.main.async {
                delegate?.requestDidSucceed(data: data)
            }
        }
    }
}
