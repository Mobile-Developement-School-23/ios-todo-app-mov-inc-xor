import Foundation

enum YandexNetworkingServiceError: Error {
    case invalidUrl
    case invalidResponse(URLResponse)
    case invalidData(String?)
    case invalidJson(Any)
    case invalidType(YandexResponse)
    case statusCode(code: Int, message: String)
}

final class YandexNetworkingService: NetworkingService {
    var lastKnownRevision = 0

    @discardableResult
    func request<T: NetworkingServiceResponse>(_ endPoint: any EndPoint, get _: T.Type) async throws -> T {
        guard let url = URL(string: endPoint.baseUrl + "/" + endPoint.path) else {
            throw YandexNetworkingServiceError.invalidUrl
        }

        var urlRequest = URLRequest(url: url)
        urlRequest.httpMethod = endPoint.method.rawValue
        urlRequest.httpBody = endPoint.request.flatMap { try? JSONEncoder().encode($0) }
        urlRequest.setValue("\(lastKnownRevision)", forHTTPHeaderField: "X-Last-Known-Revision")
        endPoint.headers.forEach {
            urlRequest.setValue($0.value, forHTTPHeaderField: $0.key)
        }

        let (data, response) = try await URLSession.shared.data(for: urlRequest)

        guard let response = response as? HTTPURLResponse else {
            throw YandexNetworkingServiceError.invalidResponse(response)
        }

        if !(200..<300).contains(response.statusCode) {
            throw YandexNetworkingServiceError.statusCode(
                code: response.statusCode,
                message: String(data: data, encoding: .utf8) ?? ""
            )
        }

        guard let result = try? JSONDecoder().decode(endPoint.responseType, from: data) as? YandexResponse else {
            let dataString = String(data: data, encoding: .utf8)
            throw YandexNetworkingServiceError.invalidData(dataString)
        }

        lastKnownRevision = result.revision

        guard let result = result as? T else {
            throw YandexNetworkingServiceError.invalidType(result)
        }

        return result
    }
}
