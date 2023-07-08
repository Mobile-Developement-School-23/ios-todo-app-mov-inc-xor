import Foundation

protocol NetworkingService {
    @discardableResult
    func request<T: NetworkingServiceResponse>(_ endPoint: any EndPoint, get _: T.Type) async throws -> T
}

enum HTTPMethod: String {
    case get = "GET"
    case post = "POST"
    case patch = "PATCH"
    case delete = "DELETE"
    case put = "PUT"
}

protocol NetworkingServiceRequest: Codable {}
protocol NetworkingServiceResponse: Codable {}

protocol EndPoint {
    var baseUrl: String { get }
    var method: HTTPMethod { get }
    var path: String { get }
    var headers: [String: String] { get }
    var request: NetworkingServiceRequest? { get }
    var responseType: NetworkingServiceResponse.Type { get }
}

protocol NetworkModel: Codable {
    associatedtype DomainType

    init(from: DomainType)
    func makeDomain() -> DomainType?
}
