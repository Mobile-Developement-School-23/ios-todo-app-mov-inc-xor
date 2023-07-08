import Foundation

enum YandexEndpoints: EndPoint {
    var baseUrl: String { "https://beta.mrdekk.ru/todobackend" }

    var headers: [String: String] {[
        "Authorization": "Bearer \(ProcessInfo.processInfo.environment["TOKEN"] ?? "")"
    ]}

    case list
    case update([TodoItem])
    case get(String)
    case add(TodoItem)
    case edit(TodoItem)
    case remove(String)
}

extension YandexEndpoints {
    var request: NetworkingServiceRequest? {
        switch self {
        case .list, .get, .remove:
            return nil
        case let .update(items):
            return ListItemsRequest(list: items.map { TodoItemNetworkModel(from: $0) })
        case let .add(item):
            return SingleItemRequest(element: TodoItemNetworkModel(from: item))
        case let .edit(item):
            return SingleItemRequest(element: TodoItemNetworkModel(from: item))
        }
    }
}

extension YandexEndpoints {
    var responseType: NetworkingServiceResponse.Type {
        switch self {
        case .list:
            return ListItemsResponse.self
        case .update:
            return ListItemsResponse.self
        case .get:
            return SingleItemResponse.self
        case .add:
            return SingleItemResponse.self
        case .edit:
            return SingleItemResponse.self
        case .remove:
            return SingleItemResponse.self
        }
    }
}

extension YandexEndpoints {
    var method: HTTPMethod {
        switch self {
        case .list:
            return .get
        case .update:
            return .patch
        case .get:
            return .get
        case .add:
            return .post
        case .edit:
            return .put
        case .remove:
            return .delete
        }
    }
}

extension YandexEndpoints {
    var path: String {
        switch self {
        case .list:
            return "list"
        case .update:
            return "list"
        case let .get(id):
            return ["list", id].joined(separator: "/")
        case .add:
            return "list"
        case let .edit(item):
            return ["list", item.id].joined(separator: "/")
        case let .remove(id):
            return ["list", id].joined(separator: "/")
        }
    }
}
