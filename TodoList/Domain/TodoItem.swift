import Foundation
import RegexBuilder

struct TodoItem {
    enum Importance: String {
        case low
        case basic
        case important
    }
    
    let id: String
    let text: String
    let importance: Importance
    let deadline: Date?
    let done: Bool
    let createdAt: Date
    let changedAt: Date?
    
    // Конструктор на все поля
    init(id: String, text: String, importance: Importance, deadline: Date?, done: Bool, createdAt: Date, changedAt: Date?) {
        self.id = id
        self.text = text
        self.importance = importance
        self.deadline = deadline
        self.done = done
        self.createdAt = createdAt
        self.changedAt = changedAt
    }
    
    // Конструктор для создания задачи пользователем в приложении
    init(text: String, importance: Importance, deadline: Date?) {
        self.init(
            id: UUID().uuidString,
            text: text,
            importance: importance,
            deadline: deadline,
            done: false,
            createdAt: Date(),
            changedAt: nil
        )
    }
}

// Для удобства тестировании
extension TodoItem: Equatable {
    static func == (lhs: TodoItem, rhs: TodoItem) -> Bool {
        return
            lhs.id == rhs.id &&
            lhs.text == rhs.text &&
            lhs.importance == rhs.importance &&
            lhs.deadline?.timeIntervalSince1970 == rhs.deadline?.timeIntervalSince1970 &&
            lhs.done == rhs.done &&
            lhs.createdAt.timeIntervalSince1970 == rhs.createdAt.timeIntervalSince1970 &&
            lhs.changedAt?.timeIntervalSince1970 == rhs.changedAt?.timeIntervalSince1970
    }
}

extension TodoItem {
    var json: Any {
        var dict: [String: Any?] = [
            "id": id,
            "text": text,
            "importance": importance.rawValue,
            "deadline": deadline?.timeIntervalSince1970,
            "done": done,
            "created_at": createdAt.timeIntervalSince1970,
            "changed_at": changedAt?.timeIntervalSince1970
        ]
        // По заданию если .basic, то сохранять не надо
        if importance == .basic {
            dict.removeValue(forKey: "importance")
        }
        // Также убираем из словаря все nil значения и возвращаем
        return dict.compactMapValues { $0 }
    }
    
    static func parse(json: Any) -> TodoItem? {
        guard let dict = json as? [String: Any] else { return nil }
        
        guard let id = dict["id"] as? String else { return nil }
        guard let text = dict["text"] as? String else { return nil }
        
        let done = dict["done"] as? Bool ?? false
        
        let importanceRaw = dict["importance"] as? Importance.RawValue ?? Importance.basic.rawValue
        let importance = Importance(rawValue: importanceRaw) ?? .basic
        
        let deadlineUnix = dict["deadline"] as? TimeInterval
        let deadline = deadlineUnix == nil ? nil : Date(timeIntervalSince1970: deadlineUnix!)
        
        guard let createdAtUnix = dict["created_at"] as? TimeInterval else { return nil }
        let createdAt = Date(timeIntervalSince1970: createdAtUnix)
        
        let changedAtUnix = dict["changed_at"] as? TimeInterval
        let changedAt = changedAtUnix == nil ? nil : Date(timeIntervalSince1970: changedAtUnix!)
        
        return self.init(
            id: id,
            text: text,
            importance: importance,
            deadline: deadline,
            done: done,
            createdAt: createdAt,
            changedAt: changedAt
        )
    }
}

extension TodoItem {
    private static let csvDelimiter = ","
    
    /*
     Храним здесь, чтобы в случае изменения/добавления полей TodoItem
     было проще все отредактировать в одном месте
     */
    static let csvTableHeader = [
        "id", "text", "importance", "deadline", "done", "created_at", "changed_at"
    ].lazy.joined(separator: "\(csvDelimiter) ")

    var csv: String {
        let fields = [
            id,
            "\"\(text.replacing("\"", with: "\"\""))\"",
            importance != .basic ? importance.rawValue : "",
            deadline != nil ? "\(deadline!.timeIntervalSince1970)" : "",
            "\(done)",
            "\(createdAt.timeIntervalSince1970)",
            changedAt != nil ? "\(changedAt!.timeIntervalSince1970)" : "",
        ]
        return fields.joined(separator: "\(Self.csvDelimiter) ")
    }
    
    static func parse(csv: String) -> TodoItem? {
        /*
         Так как split по разделителю не подходит ввиду того,
         что он может содержаться в поле text, используем регулярные выражения
        */
        
        // id может состоять из любых печатаемых символов, т.к. задается не только как UUID().uuidString
        let id = Reference(String.self)
        let idCapture = TryCapture(as: id) {
            OneOrMore { .anyGraphemeCluster }
        } transform: { String($0) }
        
        // text может содержать любые символы
        let text = Reference(String.self)
        let textCapture = TryCapture(as: text) {
            OneOrMore { .any }
        } transform: { String($0).replacing("\"\"", with: "\"") }
        
        // Может быть "important", "low" или пустой строкой, т.к. .basic мы не сохраняем
        let importance = Reference(Importance.self)
        let importanceCapture = TryCapture(as: importance) {
            ChoiceOf {
                Importance.important.rawValue
                Importance.low.rawValue
                ""
            }
        } transform: { $0 == "" ? .basic : Importance(rawValue: String($0)) }
        
        // Либо вещественное значение, либо пусто
        let deadline = Reference(Date?.self)
        let deadlineCapture = TryCapture(as: deadline) {
            ChoiceOf {
                /\d+\.\d+/
                ""
            }
        } transform: { $0 == "" ? nil : Date(timeIntervalSince1970: TimeInterval($0)!) }
        
        let done = Reference(Bool.self)
        let doneCapture = TryCapture(as: done) {
            ChoiceOf {
                "true"
                "false"
            }
        } transform: { Bool(String($0)) }
        
        let createdAt = Reference(Date.self)
        let createdAtCapture = TryCapture(as: createdAt) {
            /\d+\.\d+/
        } transform: { Date(timeIntervalSince1970: TimeInterval($0)!) }
        
        let changedAt = Reference(Date?.self)
        let changedAtCapture = TryCapture(as: changedAt) {
            ChoiceOf {
                /\d+\.\d+/
                ""
            }
        } transform: { $0 == "" ? nil : Date(timeIntervalSince1970: TimeInterval($0)!) }
        
        // Разделитель в нашем регулярном выражении
        let and = try! Regex("\(csvDelimiter)\\s*")
        
        // Шаблон, по которому разбирается вся строка csv-таблицы
        let regex = Regex {
            idCapture
            and
            /"/
            textCapture
            /"/
            and
            importanceCapture
            and
            deadlineCapture
            and
            doneCapture
            and
            createdAtCapture
            and
            changedAtCapture
        }
        
        if let result = try? regex.wholeMatch(in: csv) {
            return TodoItem(
                id: result[id],
                text: result[text],
                importance: result[importance],
                deadline: result[deadline],
                done: result[done],
                createdAt: result[createdAt],
                changedAt: result[changedAt]
            )
        }
        
        return nil
    }
}
