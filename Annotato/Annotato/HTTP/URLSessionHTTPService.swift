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
        request.httpMethod = AnnotatoHTTPMethod.get.rawValue

        let task = sharedSession.dataTask(with: request, completionHandler: makeCompletionHandler(httpMethod: .get))
        task.resume()
    }

    func get(url: String) {
        guard let url = URL(string: url) else {
            delegate?.requestDidFail(AnnotatoHTTPError.invalidURL)
            return
        }

        var request = URLRequest(url: url)
        request.httpMethod = AnnotatoHTTPMethod.get.rawValue

        let task = sharedSession.dataTask(with: request, completionHandler: makeCompletionHandler(httpMethod: .get))
        task.resume()
    }

    func post(url: String, data: Data) {
        guard let url = URL(string: url) else {
            delegate?.requestDidFail(AnnotatoHTTPError.invalidURL)
            return
        }

        var request = URLRequest(url: url)
        request.httpMethod = AnnotatoHTTPMethod.post.rawValue
        request.httpBody = data

        let task = sharedSession.dataTask(with: request, completionHandler: makeCompletionHandler(httpMethod: .post))
        task.resume()
    }

    func put(url: String, data: Data) {
        guard let url = URL(string: url) else {
            delegate?.requestDidFail(AnnotatoHTTPError.invalidURL)
            return
        }

        var request = URLRequest(url: url)
        request.httpMethod = AnnotatoHTTPMethod.put.rawValue
        request.httpBody = data

        let task = sharedSession.dataTask(with: request, completionHandler: makeCompletionHandler(httpMethod: .put))
        task.resume()
    }

    func delete(url: String) {
        guard let url = URL(string: url) else {
            delegate?.requestDidFail(AnnotatoHTTPError.invalidURL)
            return
        }

        var request = URLRequest(url: url)
        request.httpMethod = AnnotatoHTTPMethod.delete.rawValue

        let task = sharedSession.dataTask(with: request, completionHandler: makeCompletionHandler(httpMethod: .delete))
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

    private func makeCompletionHandler(httpMethod: AnnotatoHTTPMethod) -> (Data?, URLResponse?, Error?) -> Void {
        { data, response, error in
            if let error = error {
                AnnotatoLogger.error(
                    "Client error occurred during \(httpMethod) request: \(error.localizedDescription)",
                    context: "URLSessionHTTPService::\(httpMethod.rawValue.lowercased())"
                )
                delegate?.requestDidFail(error)
                return
            }

            guard let httpResponse = response as? HTTPURLResponse,
                  (200...299).contains(httpResponse.statusCode) else {
                      AnnotatoLogger.error(
                          "Server error occurred during \(httpMethod) request",
                          context: "URLSessionHTTPService::\(httpMethod.rawValue.lowercased())"
                      )
                      delegate?.requestDidFail(AnnotatoHTTPError.serverError)
                      return
                  }

//            DispatchQueue.main.async {
                delegate?.requestDidSucceed(data: data)
//            }
        }
    }
}
