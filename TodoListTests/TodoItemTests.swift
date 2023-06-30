import XCTest
@testable import TodoList

final class TodoItemTests: XCTestCase {

    // Набор TodoItem's для теста конвертируемости в Json/Csv и обратно
    let convertibilityTestItems = [
        // Интересное название задачи
        TodoItem(text: "Text1, Text2: \", ,, .; \"\"\" \"\" \"\"", importance: .basic, deadline: nil),
        // Поменяли importance и deadline, так как у них есть условия записи в json и csv
        TodoItem(text: "Text", importance: .important, deadline: Date()),
        TodoItem(id: "some id", text: "Text", importance: .low, deadline: nil, done: true, createdAt: Date(), changedAt: nil),
        TodoItem(id: "some id", text: "Text", importance: .important, deadline: Date(), done: false, createdAt: Date(), changedAt: Date())
    ]

    // Тест проверки на равенство (реализация протокола Equatable)
    func testEquatable() {
        // Заведем общую переменную с датой, поскольку каждое Date() отличается от предыдущего
        let date = Date()

        // Создаем два TodoItem's с одинаковыми значениями полей
        let item1 = TodoItem(id: "ID", text: "Text", importance: .basic, deadline: date, done: true, createdAt: date, changedAt: date)
        var item2 = TodoItem(id: "ID", text: "Text", importance: .basic, deadline: date, done: true, createdAt: date, changedAt: date)
        XCTAssertEqual(item1, item2)

        // Изменим id
        item2 = TodoItem(id: "ID1", text: "Text", importance: .basic, deadline: date, done: true, createdAt: date, changedAt: date)
        XCTAssertNotEqual(item1, item2)

        // Изменим text
        item2 = TodoItem(id: "ID", text: "Text1", importance: .basic, deadline: date, done: true, createdAt: date, changedAt: date)
        XCTAssertNotEqual(item1, item2)

        // Изменим importance
        item2 = TodoItem(id: "ID", text: "Text", importance: .low, deadline: date, done: true, createdAt: date, changedAt: date)
        XCTAssertNotEqual(item1, item2)

        // Изменим deadline
        item2 = TodoItem(id: "ID", text: "Text", importance: .basic, deadline: date.addingTimeInterval(10), done: true, createdAt: date, changedAt: date)
        XCTAssertNotEqual(item1, item2)

        // Изменим done
        item2 = TodoItem(id: "ID", text: "Text", importance: .basic, deadline: date, done: false, createdAt: date, changedAt: date)
        XCTAssertNotEqual(item1, item2)

        // Изменим createdAt
        item2 = TodoItem(id: "ID", text: "Text", importance: .basic, deadline: date, done: true, createdAt: date.addingTimeInterval(10), changedAt: date)
        XCTAssertNotEqual(item1, item2)

        // Изменим changedAt
        item2 = TodoItem(id: "ID", text: "Text", importance: .basic, deadline: date, done: true, createdAt: date, changedAt: date.addingTimeInterval(10))
        XCTAssertNotEqual(item1, item2)
    }

    // Тест конвертируемости в json и обратно
    func testJsonConvertibility() {
        convertibilityTestItems.forEach { item in
            let json = item.json
            let parsedItem = TodoItem.parse(json: json)
            XCTAssertEqual(item, parsedItem)
        }
    }

    // Тест конвертируемости в csv и обратно
    func testCsvConvertibility() {
        convertibilityTestItems.forEach { item in
            let csv = item.csv
            let parsedItem = TodoItem.parse(csv: csv)
            XCTAssertEqual(item, parsedItem)
        }
    }

    // Тест парсинга TodoItem из Json для закрытия непокрытых участков
    func testParseJson() {
        // Передали что-то непонятное
        XCTAssertNil(TodoItem.parse(json: 1))

        // Передали словарь, но без id
        XCTAssertNil(TodoItem.parse(json: ["a": 1]))

        // Нет text
        XCTAssertNil(TodoItem.parse(json: ["id": "123"]))

        // Нет created_at
        XCTAssertNil(TodoItem.parse(json: ["id": "123", "text": "Text"]))

        // Всё необходимое есть, все хорошо
        XCTAssertNotNil(TodoItem.parse(json: ["id": "123", "text": "Text", "created_at": 123.123]))

        // Тест заполнения значения importance
        var item = TodoItem.parse(json: ["id": "123", "text": "Text", "created_at": 123.123, "importance": "some importance"])
        XCTAssertNotNil(item)
        XCTAssertEqual(item?.importance, .basic)

        item = TodoItem.parse(json: ["id": "123", "text": "Text", "created_at": 123.123, "importance": "low"])
        XCTAssertNotNil(item)
        XCTAssertEqual(item?.importance, .low)
    }

    // Тест парсинга TodoItem из Csv для закрытия непокрытых участков
    func testParseCsv() {
        // Передали непонятную строчку
        XCTAssertNil(TodoItem.parse(csv: "123"))
    }
}
