import Foundation

class FileCache {
    typealias Id = String
    
    /*
     Коллекция для хранения items. Порядок нам не важен, как говорили в Техническом чате.
     Судя по всему, для поддержания порядка будем использовать сортировку по полю createdAt
     */
    private(set) var items: [Id: TodoItem] = [:]
    
    func add(item: TodoItem) {
        // Если такого itema не было, то добавляем, иначе перезаписываем
        items[item.id] = item
    }
    
    func remove(with id: String) {
        items.removeValue(forKey: id)
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
