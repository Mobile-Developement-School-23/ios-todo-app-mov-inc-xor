import Foundation

protocol YandexResponse: NetworkingServiceResponse {
    var status: String { get }
    var revision: Int { get }
}

struct SingleItemResponse: YandexResponse {
    let status: String
    let element: TodoItemNetworkModel
    let revision: Int
}

struct ListItemsResponse: YandexResponse {
    let status: String
    let list: [TodoItemNetworkModel]
    let revision: Int
}
