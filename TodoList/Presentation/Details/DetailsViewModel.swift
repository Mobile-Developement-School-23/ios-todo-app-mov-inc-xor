import Foundation

final class DetailsViewModel {

    private(set) var editingMode: Box<Bool>
    private let todoItem: TodoItem

    var changesCompletion: (() -> Void)?

    let text: Box<String>
    let importance: Box<TodoItem.Importance>
    let deadline: Box<Date?>
    let hexColor: Box<String?>

    init(item: TodoItem? = nil) {
        self.editingMode = Box(item != nil)
        self.todoItem = item ?? TodoItem(text: "", importance: .basic)

        self.text = Box(self.todoItem.text)
        self.importance = Box(self.todoItem.importance)
        self.deadline = Box(self.todoItem.deadline)
        self.hexColor = Box(self.todoItem.hexColor)
    }

    func save() throws {
        let item = TodoItem(
            id: todoItem.id,
            text: text.value,
            importance: importance.value,
            deadline: deadline.value,
            done: todoItem.done,
            createdAt: todoItem.createdAt,
            changedAt: editingMode.value ? Date() : todoItem.changedAt,
            hexColor: hexColor.value
        )

        let fileCache = FileCache()
        try? fileCache.importJson(filename: Res.fileStorageName)
        fileCache.add(item: item)
        try fileCache.exportJson(filename: Res.fileStorageName)

        changesCompletion?()
    }

    func remove() throws {
        if !editingMode.value {
            return
        }

        let fileCache = FileCache()
        try? fileCache.importJson(filename: Res.fileStorageName)
        fileCache.remove(with: todoItem.id)
        try fileCache.exportJson(filename: Res.fileStorageName)

        self.editingMode.value = false

        changesCompletion?()
    }
}
