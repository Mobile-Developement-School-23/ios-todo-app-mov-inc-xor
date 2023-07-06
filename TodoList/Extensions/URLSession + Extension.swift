import Foundation

enum NetworkError: Error {
    case noData
    case statusCode(Int)
}

private let successCode = 200..<300

extension URLSession {
    func dataTask(for urlRequest: URLRequest) async throws -> (Data, URLResponse) {
        var task: URLSessionDataTask?

        return try await withTaskCancellationHandler {
            return try await withCheckedThrowingContinuation { continuation in
                task = self.dataTask(with: urlRequest) { (data, response, error) in
                    if let res = response as? HTTPURLResponse, let data {
                        if successCode.contains(res.statusCode) {
                            continuation.resume(returning: (data, res))
                        } else if let error {
                            continuation.resume(throwing: error)
                        } else {
                            continuation.resume(throwing: NetworkError.statusCode(res.statusCode))
                        }
                    } else {
                        continuation.resume(throwing: NetworkError.noData)
                    }
                }
                task?.resume()
            }
        } onCancel: { [weak task] in
            task?.cancel()
        }
    }
}
