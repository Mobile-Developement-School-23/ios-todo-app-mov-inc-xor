import XCTest
@testable import TodoList

final class FileCacheTests: XCTestCase {

    // TodoItem's для теста импорта/экспорта
    let items = [
        TodoItem(
            id: "123",
            text: "Text1, Text2: \", ,, .; \"\"\" \"\" \"\"",
            importance: .basic,
            deadline: nil,
            done: true,
            createdAt: Date(),
            changedAt: nil
        ),
        TodoItem(
            id: UUID().uuidString,
            text: "Text",
            importance: .important,
            deadline: Date(),
            done: false,
            createdAt: Date(),
            changedAt: Date()
        )
    ]

    // Тест добавления/удаления TodoItem's из FileCache
    func testAddRemove() {
        let item = TodoItem(text: "Text", importance: .basic, deadline: nil)

        let fileCache = FileCache()
        fileCache.add(item: item)

        // Первый элемент должен быть item
        XCTAssertEqual(fileCache.items.first?.value, item)

        fileCache.remove(with: item.id)

        // fc.items должен быть пустым
        XCTAssertEqual(fileCache.items.count, 0)
    }

    func testJsonImportExport() throws {
        /*
         Добавляем в FileCache items, экспортируем, очищаем, импортируем.
         В итоге в FileCache должны быть те же элементы, которые мы в него записали изначально (то есть items)
         */
        let filename = "test.json"

        let fileCache = FileCache()
        items.forEach { fileCache.add(item: $0) }

        try fileCache.exportJson(filename: filename)

        fileCache.clear()

        try fileCache.importJson(filename: filename)

        XCTAssertEqual(fileCache.items.count, items.count)

        for item in items {
            XCTAssertEqual(item, fileCache.items[item.id])
        }
    }

    func testCsvImportExport() throws {
        let filename = "test.csv"

        let fileCache = FileCache()
        items.forEach { fileCache.add(item: $0) }

        try fileCache.exportCsv(filename: filename)

        fileCache.clear()

        try fileCache.importCsv(filename: filename)

        XCTAssertEqual(fileCache.items.count, items.count)

        for item in items {
            XCTAssertEqual(item, fileCache.items[item.id])
        }
    }

    func testJsonImport() throws {
        let filename = "test.json"
        let url = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)[0].appending(path: filename)
        let fileCache = FileCache()

        // Несуществующий файл
        XCTAssertThrowsError(try fileCache.importJson(filename: "123"))

        // Файл не является json
        let json1 = "123"
        try json1.data(using: .utf8)?.write(to: url)
        XCTAssertThrowsError(try fileCache.importJson(filename: filename))
        XCTAssertEqual(fileCache.items.count, 0)

        // Файл прочитает без ошибок, но импортировать нечего, т.к. в файле нет задач
        let json2 = ["123": "123"]
        try JSONSerialization.data(withJSONObject: json2).write(to: url)
        XCTAssertNoThrow(try fileCache.importJson(filename: filename))
        XCTAssertEqual(fileCache.items.count, 0)

        // Все хорошо
        let json3 = [["id": "123", "text": "Text", "created_at": 123.123]]
        try JSONSerialization.data(withJSONObject: json3).write(to: url)
        XCTAssertNoThrow(try fileCache.importJson(filename: filename))
        XCTAssertEqual(fileCache.items.count, 1)
    }

    func testCsvImport() throws {
        let filename = "test.csv"
        let url = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)[0].appending(path: filename)
        let fileCache = FileCache()

        // Ничего не импортирует и не выдаст исключение
        try "123".data(using: .utf8)!.write(to: url)
        XCTAssertNoThrow(try fileCache.importCsv(filename: filename))
        XCTAssertEqual(fileCache.items.count, 0)

        // Все ок, добавит один TodoItem
        let header = TodoItem.csvTableHeader
        let csv = header + "\n" + TodoItem(text: "Text", importance: .basic, deadline: nil).csv
        try csv.data(using: .utf8)!.write(to: url)
        XCTAssertNoThrow(try fileCache.importCsv(filename: filename))
        XCTAssertEqual(fileCache.items.count, 1)
    }
}
