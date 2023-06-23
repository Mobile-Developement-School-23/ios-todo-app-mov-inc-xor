final class ImportanceOptionViewModel {
    let importance: Box<TodoItem.Importance>
    
    var didChangeImportance: ((_ importance: TodoItem.Importance) -> ())?
    
    init(importance: TodoItem.Importance) {
        self.importance = Box(importance)
    }
}
