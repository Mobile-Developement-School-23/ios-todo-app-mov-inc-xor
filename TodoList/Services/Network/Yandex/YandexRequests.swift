import Foundation

struct SingleItemRequest: NetworkingServiceRequest {
    let element: TodoItemNetworkModel
}

struct ListItemsRequest: NetworkingServiceRequest {
    let list: [TodoItemNetworkModel]
}
