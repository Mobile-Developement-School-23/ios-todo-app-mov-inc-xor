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
    let hexColor: String?

    init(
        id: String = UUID().uuidString,
        text: String,
        importance: Importance,
        deadline: Date? = nil,
        done: Bool = false,
        createdAt: Date = Date(),
        changedAt: Date? = nil,
        hexColor: String? = nil
    ) {
        self.id = id
        self.text = text
        self.importance = importance
        self.deadline = deadline
        self.done = done
        self.createdAt = createdAt
        self.changedAt = changedAt
        self.hexColor = hexColor
    }
}

extension TodoItem {
    private static let kId = "id"
    private static let kText = "text"
    private static let kImportance = "importance"
    private static let kDeadline = "deadline"
    private static let kDone = "done"
    private static let kCreatedAt = "created_at"
    private static let kChangedAt = "changed_at"
    private static let kHexColor = "hex_color"
}

extension TodoItem: Equatable {
    static func == (lhs: TodoItem, rhs: TodoItem) -> Bool {
        return
            lhs.id == rhs.id &&
            lhs.text == rhs.text &&
            lhs.importance == rhs.importance &&
            lhs.deadline?.timeIntervalSince1970 == rhs.deadline?.timeIntervalSince1970 &&
            lhs.done == rhs.done &&
            lhs.createdAt.timeIntervalSince1970 == rhs.createdAt.timeIntervalSince1970 &&
            lhs.changedAt?.timeIntervalSince1970 == rhs.changedAt?.timeIntervalSince1970 &&
            lhs.hexColor == rhs.hexColor
    }
}

extension TodoItem {
    var json: Any {
        var dict: [String: Any?] = [
            Self.kId: id,
            Self.kText: text,
            Self.kImportance: importance.rawValue,
            Self.kDeadline: deadline?.timeIntervalSince1970,
            Self.kDone: done,
            Self.kCreatedAt: createdAt.timeIntervalSince1970,
            Self.kChangedAt: changedAt?.timeIntervalSince1970,
            Self.kHexColor: hexColor
        ]
        // По заданию если .basic, то сохранять не надо
        if importance == .basic {
            dict.removeValue(forKey: Self.kImportance)
        }
        // Также убираем из словаря все nil значения и возвращаем
        return dict.compactMapValues { $0 }
    }

    static func parse(json: Any) -> TodoItem? {
        guard let dict = json as? [String: Any] else {
            return nil
        }

        guard
            let id = dict[kId] as? String,
            let text = dict[kText] as? String,
            let createdAt =  (dict[kCreatedAt] as? TimeInterval).flatMap({ Date(timeIntervalSince1970: $0) })
        else {
            return nil
        }

        let done = dict[kDone] as? Bool ?? false
        let importance = (dict[kImportance] as? String).flatMap({ Importance(rawValue: $0) }) ?? .basic
        let deadline = (dict[kDeadline] as? TimeInterval).flatMap({ Date(timeIntervalSince1970: $0) })
        let changedAt = (dict[kChangedAt] as? TimeInterval).flatMap({ Date(timeIntervalSince1970: $0) })
        let hexColor = dict[kHexColor] as? String

        return self.init(
            id: id,
            text: text,
            importance: importance,
            deadline: deadline,
            done: done,
            createdAt: createdAt,
            changedAt: changedAt,
            hexColor: hexColor
        )
    }
}

extension TodoItem {
    private static let csvDelimiter = ","

    static let csvTableHeader = [
        kId, kText, kImportance, kDeadline, kDone, kCreatedAt, kChangedAt, kHexColor
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
            hexColor ?? ""
        ]
        return fields.joined(separator: "\(Self.csvDelimiter) ")
    }

    private static let idRef = Reference(String.self)
    private static let idCapture = TryCapture(as: idRef) {
        OneOrMore { .anyGraphemeCluster }
    } transform: { String($0) }

    private static let textRef = Reference(String.self)
    private static let textCapture = TryCapture(as: textRef) {
        OneOrMore { .any }
    } transform: { String($0).replacing("\"\"", with: "\"") }

    private static let importanceRef = Reference(Importance.self)
    private static let importanceCapture = TryCapture(as: importanceRef) {
        ChoiceOf {
            Importance.important.rawValue
            Importance.low.rawValue
            ""
        }
    } transform: { $0 == "" ? .basic : Importance(rawValue: String($0)) }

    private static let deadlineRef = Reference(Date?.self)
    private static let deadlineCapture = TryCapture(as: deadlineRef) {
        ChoiceOf {
            /\d+\.\d+/
            ""
        }
    } transform: { $0 == "" ? nil : Date(timeIntervalSince1970: TimeInterval($0)!) }

    private static let doneRef = Reference(Bool.self)
    private static let doneCapture = TryCapture(as: doneRef) {
        ChoiceOf {
            "true"
            "false"
        }
    } transform: { Bool(String($0)) }

    private static let createdAtRef = Reference(Date.self)
    private static let createdAtCapture = TryCapture(as: createdAtRef) {
        /\d+\.\d+/
    } transform: { Date(timeIntervalSince1970: TimeInterval($0)!) }

    private static let changedAtRef = Reference(Date?.self)
    private static let changedAtCapture = TryCapture(as: changedAtRef) {
        ChoiceOf {
            /\d+\.\d+/
            ""
        }
    } transform: { $0 == "" ? nil : Date(timeIntervalSince1970: TimeInterval($0)!) }

    private static let hexColorRef = Reference(String?.self)
    private static let hexColorCapture = TryCapture(as: hexColorRef) {
        /#[A-F0-9] {6}/
    } transform: { String($0) }

    static func parse(csv: String) -> TodoItem? {
        guard let and = try? Regex("\(csvDelimiter)\\s*") else {
            return nil
        }

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
            and
            hexColorCapture
        }

        if let result = try? regex.wholeMatch(in: csv) {
            return TodoItem(
                id: result[idRef],
                text: result[textRef],
                importance: result[importanceRef],
                deadline: result[deadlineRef],
                done: result[doneRef],
                createdAt: result[createdAtRef],
                changedAt: result[changedAtRef],
                hexColor: result[hexColorRef]
            )
        }

        return nil
    }
}
