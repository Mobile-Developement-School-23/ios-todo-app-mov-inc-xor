final class TodoListViewModel {
    private(set) var items: [String: TodoItem]

    let tableItems: Box<[TodoItem]>
    let showCompleted: Box<Bool>
    let loading: Box<Bool>

    let fileCache: FileCache
    let networkService: any NetworkingService
    let retryManager: RetryManager

    init(
        fileCache: FileCache,
        networkService: any NetworkingService,
        retryManager: RetryManager
    ) {
        self.items = [:]

        self.tableItems = Box([])
        self.showCompleted = Box(false)
        self.loading = Box(false)

        self.fileCache = fileCache
        self.networkService = networkService
        self.retryManager = retryManager
    }

    @MainActor
    func fetchTodoItems() {
        loading.value = true

        // Загрузим TodoItem's сначала из кэша, чтобы было что показать сразу
        try? fileCache.importJson(filename: Res.fileStorageName)
        items = fileCache.items
        tableItems.value = prepareToDisplay(self.items)

        retryManager.run { [weak self] in
            guard let self else { return }

            // А затем из сети
            let response = try await self.networkService.request(YandexEndpoints.list, get: ListItemsResponse.self)
            response.list.forEach { networkItemModel in
                if let item = networkItemModel.makeDomain() {
                    self.items[item.id] = item
                }
            }

            // При этом надо перезапизать устаревшие данные из сети новыми из локального хранилища
            self.fileCache.items.forEach {
                self.items[$0.key] = $0.value
            }

            self.tableItems.value = self.prepareToDisplay(self.items)

            /* Сохраним в сеть в том числе и то, что подрузили из файла,
             так как при прошлом запуске могли не синхронизировать
             */
            try await self.networkService.request(
                YandexEndpoints.update(Array(self.items.values)),
                get: ListItemsResponse.self
            )

            // Также сохраним локально
            try? self.fileCache.exportJson(filename: Res.fileStorageName)

            self.loading.value = false
        } onTimeout: { [weak self] error in
            self?.loading.value = false
            print(error)
        }
    }

    private func prepareToDisplay(_ items: [String: TodoItem]) -> [TodoItem] {
        return items.values
            .sorted { $0.createdAt < $1.createdAt }
            .filter { [weak self] in
                guard let showCompleted = self?.showCompleted.value else {
                    return true
                }
                if showCompleted {
                    return true
                }
                return !$0.done
            }
    }

    func toggleCompletedItems() {
        showCompleted.value = !showCompleted.value
        tableItems.value = prepareToDisplay(items)
    }

    @MainActor
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

        items[editedItem.id] = editedItem
        tableItems.value = prepareToDisplay(items)

        fileCache.add(item: editedItem)
        try? fileCache.exportJson(filename: Res.fileStorageName)

        loading.value = true

        retryManager.run { [weak self] in
            try await self?.networkService.request(YandexEndpoints.edit(editedItem), get: SingleItemResponse.self)
            self?.loading.value = false
        } onTimeout: { [weak self] error in
            self?.loading.value = false
            print(error)
        }
    }

    @MainActor
    func add(_ text: String) {
        let item = TodoItem(text: text, importance: .basic)
        items[item.id] = item
        tableItems.value = prepareToDisplay(items)

        fileCache.add(item: item)
        try? fileCache.exportJson(filename: Res.fileStorageName)

        loading.value = true

        retryManager.run { [weak self] in
            try await self?.networkService.request(YandexEndpoints.add(item), get: SingleItemResponse.self)
            self?.loading.value = false
        } onTimeout: { [weak self] error in
            self?.loading.value = false
            print(error)
        }
    }

    @MainActor
    func remove(todoId: String) {
        items.removeValue(forKey: todoId)
        tableItems.value = prepareToDisplay(items)

        fileCache.remove(with: todoId)
        try? fileCache.exportJson(filename: Res.fileStorageName)

        loading.value = true

        retryManager.run { [weak self] in
            try await self?.networkService.request(YandexEndpoints.remove(todoId), get: SingleItemResponse.self)
            self?.loading.value = false
        } onTimeout: { [weak self] error in
            self?.loading.value = false
            print(error)
        }
    }
}
