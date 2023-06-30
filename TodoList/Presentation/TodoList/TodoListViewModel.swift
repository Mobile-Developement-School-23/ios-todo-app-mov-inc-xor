final class TodoListViewModel {
    let fileCache: FileCache
    let items: Box<[TodoItem]>
    let showCompleted: Box<Bool>
    
    var shownItems: [TodoItem] {
        return allItems.filter { [weak self] in
            guard let showCompleted = self?.showCompleted.value else {
                return true
            }
            if showCompleted {
                return true
            }
            return !$0.done
        }
    }
    
    var allItems: [TodoItem] {
        return Array(fileCache.items.values).sorted { $0.createdAt < $1.createdAt }
    }
    
    init() {
        self.fileCache = FileCache()
        self.items = Box([])
        self.showCompleted = Box(false)
        
        fetchTodoItems()
    }
    
    func fetchTodoItems() {
        fileCache.clear()
        try? fileCache.importJson(filename: R.fileStorageName)
        items.value = shownItems
    }
    
    func setDone(todoId: String, _ done: Bool) {
        guard let item = fileCache.items[todoId] else {
            return
        }
        
        let editedItem = TodoItem(
            id: item.id,
            text: item.text,
            importance: item.importance,
            deadline: item.deadline,
            done: done,
            createdAt: item.createdAt,
            changedAt: item.changedAt,
            hexColor: item.hexColor
        )
        
        fileCache.add(item: editedItem)

        items.value = shownItems
        try? fileCache.exportJson(filename: R.fileStorageName)
    }
    
    func add(_ text: String) {
        let item = TodoItem(text: text, importance: .basic)
        fileCache.add(item: item)
        items.value = shownItems
        try? fileCache.exportJson(filename: R.fileStorageName)
    }
    
    func remove(todoId: String) {
        fileCache.remove(with: todoId)
        items.value = shownItems
        try? fileCache.exportJson(filename: R.fileStorageName)
    }
}
