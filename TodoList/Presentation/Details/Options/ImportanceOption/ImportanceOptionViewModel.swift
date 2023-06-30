final class ImportanceOptionViewModel {
    let importance: Box<TodoItem.Importance>

    var didChangeImportance: ((_ importance: TodoItem.Importance) -> Void)?

    init(importance: TodoItem.Importance) {
        self.importance = Box(importance)
    }
}
