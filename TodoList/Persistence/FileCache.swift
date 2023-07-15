import Foundation
import SQLite

enum FileCacheError: Error {
    case noConnection
}

class FileCache {
    typealias TodoItemId = String

    private(set) var items: [TodoItemId: TodoItem] = [:]

    private var filename: String

    private var connection: Connection?

    private let todoListTable = Table("todo_list")

    private let id = Expression<String>("id")
    private let text = Expression<String>("text")
    private let importance = Expression<String>("importance")
    private let deadline = Expression<Date?>("deadline")
    private let done = Expression<Bool>("done")
    private let createdAt = Expression<Date>("created_at")
    private let changedAt = Expression<Date?>("changed_at")
    private let hexColor = Expression<String?>("color")

    init(filename: String) {
        let path = FileCache.getDocumentPath(filename: "db.sqlite3")

        self.filename = filename
        self.connection = try? Connection(path.absoluteString)

        if self.connection == nil {
            print("Не удалось инициализировать подключение к БД")
        }
    }

    @discardableResult
    func add(item: TodoItem) -> TodoItem? {
        let oldItem = items[item.id]
        items[item.id] = item
        return oldItem
    }

    @discardableResult
    func remove(with id: String) -> TodoItem? {
        return items.removeValue(forKey: id)
    }

    func clear() {
        items = [:]
    }

    public static func getDocumentPath(filename: String) -> URL {
        let path = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)[0]
        return path.appending(path: filename)
    }
}

extension FileCache {
    /*
     Намеренно здесь и далее делаем функцию throws, чтобы обрабатывать ошибки выше в стеке вызовов
     и выводить пользователю сообщение об ошибке
     */
    func importJson() throws {
        let url = Self.getDocumentPath(filename: self.filename)
        let data = try Data(contentsOf: url)
        let jsonObject = try JSONSerialization.jsonObject(with: data)
        let arrayOfJson = jsonObject as? [Any] ?? []
        let items = arrayOfJson.compactMap { TodoItem.parse(json: $0) }

        items.forEach { add(item: $0) }
    }

    func exportJson() throws {
        let url = Self.getDocumentPath(filename: self.filename)
        let data = try JSONSerialization.data(withJSONObject: items.values.map { $0.json })
        try data.write(to: url, options: [])
    }
}

extension FileCache {
    func importCsv() throws {
        let url = Self.getDocumentPath(filename: self.filename)
        let csv = try String(contentsOf: url)
        let items = csv.split(separator: "\n")[1...].map(String.init).compactMap { TodoItem.parse(csv: $0) }

        items.forEach { add(item: $0) }
    }

    func exportCsv() throws {
        let url = Self.getDocumentPath(filename: self.filename)
        let header = TodoItem.csvTableHeader
        let csv = header + "\n" + items.values.map { $0.csv }.joined(separator: "\n")
        try csv.write(to: url, atomically: true, encoding: .utf8)
    }
}

extension FileCache {
    private func createTable() throws {
        try connection?.run(todoListTable.create(ifNotExists: true) { table in
            table.column(id, primaryKey: true)
            table.column(text)
            table.column(importance)
            table.column(deadline)
            table.column(done)
            table.column(createdAt)
            table.column(changedAt)
            table.column(hexColor)
        })
    }

    func save() throws {
        guard let connection = self.connection else {
            throw FileCacheError.noConnection
        }

        let drop = todoListTable.drop(ifExists: true)

        try connection.run(drop)
        try createTable()

        try items.forEach { [weak connection] in
            let item = $0.value
            try connection?.run(todoListTable.insert(
                id <- item.id,
                text <- item.text,
                importance <- item.importance.rawValue,
                deadline <- item.deadline,
                done <- item.done,
                createdAt <- item.createdAt,
                changedAt <- item.changedAt,
                hexColor <- item.hexColor
            ))
        }
    }

    func load() throws {
        guard let connection = self.connection else {
            throw FileCacheError.noConnection
        }

        for item in try connection.prepare(todoListTable) {
            add(item: TodoItem(
                id: item[id],
                text: item[text],
                importance: TodoItem.Importance(rawValue: item[importance]) ?? .basic,
                deadline: item[deadline],
                done: item[done],
                createdAt: item[createdAt],
                changedAt: item[changedAt],
                hexColor: item[hexColor]
            ))
        }
    }
}
