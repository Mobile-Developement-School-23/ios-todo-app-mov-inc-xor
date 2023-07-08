import Foundation

struct TodoItemNetworkModel {
    let id: String
    let text: String
    let importance: String
    let deadline: Int?
    let done: Bool
    let createdAt: Int
    let changedAt: Int
    let color: String?
    let lastUpdatedBy: String

    enum CodingKeys: String, CodingKey {
        case id, text, importance, deadline, done, color
        case createdAt = "created_at"
        case changedAt = "changed_at"
        case lastUpdatedBy = "last_updated_by"
    }
}

extension TodoItemNetworkModel: NetworkModel {
    init(from: TodoItem) {
        let id = from.id
        let text = from.text
        let importance = from.importance.rawValue
        let deadline = from.deadline.flatMap { Int($0.timeIntervalSince1970) }
        let done = from.done
        let createdAt = Int(from.createdAt.timeIntervalSince1970)
        let changedAt = from.changedAt.flatMap { Int($0.timeIntervalSince1970) } ?? createdAt
        let color = from.hexColor
        let lastUpdatedBy = "iphone"

        self.init(
            id: id,
            text: text,
            importance: importance,
            deadline: deadline,
            done: done,
            createdAt: createdAt,
            changedAt: changedAt,
            color: color,
            lastUpdatedBy: lastUpdatedBy
        )
    }

    func makeDomain() -> TodoItem? {
        guard let importance = TodoItem.Importance(rawValue: importance) else {
            return nil
        }

        let deadline = deadline.flatMap { Date(timeIntervalSince1970: TimeInterval($0)) }
        let changedAt = createdAt == changedAt ? nil : Date(timeIntervalSince1970: TimeInterval(changedAt))
        let createdAt = Date(timeIntervalSince1970: TimeInterval(createdAt))

        return TodoItem(
            id: id,
            text: text,
            importance: importance,
            deadline: deadline,
            done: done,
            createdAt: createdAt,
            changedAt: changedAt,
            hexColor: color
        )
    }
}
