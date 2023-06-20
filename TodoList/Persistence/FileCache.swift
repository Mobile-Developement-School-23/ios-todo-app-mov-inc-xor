import Foundation

class FileCache {
    typealias Id = String
    
    private(set) var items: [Id: TodoItem] = [:]
    
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
    
    private static func getDocumentPath(filename: String) -> URL {
        let path = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)[0]
        return path.appending(path: filename)
    }
}

extension FileCache {
    /*
     Намеренно здесь и далее делаем функцию throws, чтобы обрабатывать ошибки выше в стеке вызовов
     и выводить пользователю сообщение об ошибке
     */
    func importJson(filename: String) throws {
        let url = Self.getDocumentPath(filename: filename)
        let data = try Data(contentsOf: url)
        let jsonObject = try JSONSerialization.jsonObject(with: data)
        let arrayOfJson = jsonObject as? [Any] ?? []
        let items = arrayOfJson.compactMap { TodoItem.parse(json: $0) }

        items.forEach { add(item: $0) }
    }
    
    func exportJson(filename: String) throws {
        let url = Self.getDocumentPath(filename: filename)
        let data = try JSONSerialization.data(withJSONObject: items.values.map { $0.json })
        try data.write(to: url, options: [])
    }
}

extension FileCache {
    func importCsv(filename: String) throws {
        let url = Self.getDocumentPath(filename: filename)
        let csv = try String(contentsOf: url)
        let items = csv.split(separator: "\n")[1...].map(String.init).compactMap { TodoItem.parse(csv: $0) }
        
        items.forEach { add(item: $0) }
    }
    
    func exportCsv(filename: String) throws {
        let url = Self.getDocumentPath(filename: filename)
        let header = TodoItem.csvTableHeader
        let csv = header + "\n" + items.values.map { $0.csv }.joined(separator: "\n")
        try csv.write(to: url, atomically: true, encoding: .utf8)
    }
}
