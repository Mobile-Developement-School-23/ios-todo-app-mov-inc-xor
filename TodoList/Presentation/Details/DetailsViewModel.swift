import Foundation

final class DetailsViewModel {

    private(set) var editingMode: Box<Bool>
    private let todoItem: TodoItem

    var changesCompletion: (() -> Void)?

    let text: Box<String>
    let importance: Box<TodoItem.Importance>
    let deadline: Box<Date?>
    let hexColor: Box<String?>

    let retryManager: RetryManager
    let networkService: any NetworkingService

    init(
        retryManager: RetryManager,
        networkService: any NetworkingService,
        item: TodoItem? = nil
    ) {
        self.editingMode = Box(item != nil)
        self.todoItem = item ?? TodoItem(text: "", importance: .basic)

        self.text = Box(self.todoItem.text)
        self.importance = Box(self.todoItem.importance)
        self.deadline = Box(self.todoItem.deadline)
        self.hexColor = Box(self.todoItem.hexColor)

        self.retryManager = retryManager
        self.networkService = networkService
    }

    @MainActor
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

        let fileCache = FileCache(filename: Res.fileStorageName)
        try? fileCache.load()
        fileCache.add(item: item)
        try fileCache.save()

        retryManager.run { [weak self] in
            guard let self else { return }
            if self.editingMode.value {
                try await self.networkService.request(YandexEndpoints.edit(item), get: SingleItemResponse.self)
            } else {
                try await self.networkService.request(YandexEndpoints.add(item), get: SingleItemResponse.self)
            }
        } onTimeout: { error in
            print(error)
        }

        changesCompletion?()
    }

    @MainActor
    func remove() throws {
        if !editingMode.value {
            return
        }

        let fileCache = FileCache(filename: Res.fileStorageName)
        try? fileCache.load()
        fileCache.remove(with: todoItem.id)
        try fileCache.save()

        self.editingMode.value = false

        retryManager.run { [weak self] in
            guard let self else { return }
            try await self.networkService.request(
                YandexEndpoints.remove(self.todoItem.id),
                get: SingleItemResponse.self
            )
            self.changesCompletion?()
        } onTimeout: { error in
            print(error)
        }
    }
}
