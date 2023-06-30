import UIKit
import CocoaLumberjackSwift

class TodoListViewController: UIViewController {
    var viewModel: TodoListViewModel

    private static let cellReuseIdentifier = "todo_cell"

    private lazy var doneCountLabel: UILabel = {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.textColor = R.Colors.disabledText
        label.font = .systemFont(ofSize: 15)
        return label
    }()

    private lazy var toggleCompletedButton: UIButton = {
        let action = UIAction { [weak self] _ in
            guard let showCompleted = self?.viewModel.showCompleted.value else { return }
            self?.viewModel.showCompleted.value = !showCompleted
        }

        let button = UIButton(type: .system)
        button.translatesAutoresizingMaskIntoConstraints = false
        button.setTitle("Показать", for: .normal)
        button.titleLabel?.font = .boldSystemFont(ofSize: 15)
        button.addAction(action, for: .touchUpInside)
        return button
    }()

    private lazy var topViewsContainer: UIStackView = {
        let container = UIStackView()
        container.translatesAutoresizingMaskIntoConstraints = false
        container.axis = .horizontal
        container.spacing = 16
        container.distribution = .fillEqually
        return container
    }()

    private lazy var todoListHeightConstraint: NSLayoutConstraint = {
        let constraint = todoListView.heightAnchor.constraint(equalToConstant: todoListView.contentSize.height)
        return constraint
    }()

    private lazy var todoListView: UITableView = {
        let table = UITableView()
        table.translatesAutoresizingMaskIntoConstraints = false
        table.delegate = self
        table.dataSource = self
        table.isScrollEnabled = false
        table.bounces = false
        table.layer.cornerRadius = 16
        table.clipsToBounds = true
        table.separatorInset.left = 52
        table.showsVerticalScrollIndicator = false
        table.showsHorizontalScrollIndicator = false
        table.keyboardDismissMode = .onDrag
        table.register(UITableViewCell.self, forCellReuseIdentifier: Self.cellReuseIdentifier)
        return table
    }()

    private lazy var contentView: UIStackView = {
        let stack = UIStackView()
        stack.translatesAutoresizingMaskIntoConstraints = false
        stack.axis = .vertical
        stack.distribution = .equalSpacing
        stack.spacing = 12
        stack.alignment = .center
        return stack
    }()

    private lazy var scrollView: UIScrollView = {
        let scrollView = UIScrollView()
        scrollView.translatesAutoresizingMaskIntoConstraints = false
        scrollView.alwaysBounceVertical = true
        return scrollView
    }()

    private lazy var addButton: AddButton = {
        let action = UIAction { [weak self] _ in
            self?.presentDetailsView()
        }

        let button = AddButton()
        button.translatesAutoresizingMaskIntoConstraints = false
        button.addAction(action, for: .touchUpInside)
        return button
    }()

    init(viewModel: TodoListViewModel) {
        self.viewModel = viewModel
        super.init(nibName: nil, bundle: nil)
        DDLogDebug("\(Self.description()) init")
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    deinit {
        NotificationCenter.default.removeObserver(self)
        DDLogDebug("\(Self.description()) deinit")
    }

    override func viewDidLoad() {
        bind()
        setup()
        addKeyboardObservers()
    }

    override func viewDidLayoutSubviews() {
        todoListHeightConstraint.constant = todoListView.contentSize.height
    }

    private func presentDetailsView(tableView: UITableView? = nil, indexPath: IndexPath? = nil) {
        let vm = DetailsViewModel(item: indexPath.flatMap { viewModel.items.value[$0.row] })
        vm.changesCompletion = { [weak self] in
            self?.viewModel.fetchTodoItems()
        }

        let vc = DetailsViewController(viewModel: vm)
        present(UINavigationController(rootViewController: vc), animated: true)

        if let tableView, let indexPath {
            tableView.deselectRow(at: indexPath, animated: true)
        }
    }
}

extension TodoListViewController {
    @objc private func keyboardWillShow(_ notification: Notification) {
        guard
            let userInfo = notification.userInfo,
            let keyboardFrame = userInfo[UIResponder.keyboardFrameEndUserInfoKey] as? CGRect
        else {
            return
        }
        scrollView.contentInset.bottom += keyboardFrame.height
    }

    @objc private func keyboardWillHide(_ notification: Notification) {
        let contentInset = UIEdgeInsets.zero
        scrollView.contentInset = contentInset
    }

    private func addKeyboardObservers() {
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillShow), name: UIResponder.keyboardWillShowNotification, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillHide), name: UIResponder.keyboardWillHideNotification, object: nil)
    }
}

extension TodoListViewController {
    private func bind() {
        viewModel.items.bind { [weak self] _ in
            guard let self else { return }

            self.doneCountLabel.text = "Выполнено — \(Array(self.viewModel.allItems.filter { $0.done }).count)"
            self.todoListView.reloadData()
            DispatchQueue.main.async {
                self.view.setNeedsLayout()
                self.view.layoutIfNeeded()

                self.todoListHeightConstraint.constant = self.todoListView.contentSize.height
            }

        }

        viewModel.showCompleted.bind { [weak self] showCompleted in
            guard let self else { return }
            self.toggleCompletedButton.setTitle(showCompleted ? "Скрыть" : "Показать", for: .normal)
            self.toggleCompletedButton.contentHorizontalAlignment = .right
            self.viewModel.items.value = self.viewModel.shownItems
        }
    }
}

extension TodoListViewController {
    private func setup() {
        title = "Мои дела"

        let textAttributes: [NSAttributedString.Key: Any] = [
            .foregroundColor: R.Colors.text as Any
        ]

        navigationController?.navigationBar.layoutMargins.left = 32
        navigationController?.view.backgroundColor = R.Colors.appBackground
        navigationController?.navigationBar.isTranslucent = false
        navigationController?.navigationBar.barTintColor = R.Colors.navBarBackground
        navigationController?.navigationBar.titleTextAttributes = textAttributes
        navigationController?.navigationBar.largeTitleTextAttributes = textAttributes
        navigationController?.navigationBar.prefersLargeTitles = true

        topViewsContainer.addArrangedSubview(doneCountLabel)
        topViewsContainer.addArrangedSubview(toggleCompletedButton)

        contentView.addArrangedSubview(topViewsContainer)
        contentView.addArrangedSubview(todoListView)

        scrollView.addSubview(contentView)
        scrollView.addSubview(addButton)

        view.addSubview(scrollView)

        NSLayoutConstraint.activate([
            scrollView.leadingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.leadingAnchor),
            scrollView.trailingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.trailingAnchor),
            scrollView.topAnchor.constraint(equalTo: view.topAnchor),
            scrollView.bottomAnchor.constraint(equalTo: view.bottomAnchor),

            contentView.leadingAnchor.constraint(equalTo: scrollView.leadingAnchor, constant: 16),
            contentView.trailingAnchor.constraint(equalTo: scrollView.trailingAnchor, constant: -16),
            contentView.topAnchor.constraint(equalTo: scrollView.topAnchor, constant: 8),
            contentView.bottomAnchor.constraint(equalTo: scrollView.bottomAnchor),
            contentView.widthAnchor.constraint(equalTo: scrollView.widthAnchor, constant: -32),

            topViewsContainer.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 16),
            topViewsContainer.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -16),

            todoListView.widthAnchor.constraint(equalTo: contentView.widthAnchor),

            todoListHeightConstraint,

            addButton.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            addButton.bottomAnchor.constraint(equalTo: view.bottomAnchor, constant: -54)
        ])
    }
}

extension TodoListViewController: UITableViewDelegate {
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        if indexPath.row == viewModel.items.value.count {
            return
        }

        presentDetailsView(tableView: tableView, indexPath: indexPath)
    }

    func tableView(_ tableView: UITableView, leadingSwipeActionsConfigurationForRowAt indexPath: IndexPath) -> UISwipeActionsConfiguration? {
        if indexPath.row == viewModel.items.value.count {
            return nil
        }

        let action = UIContextualAction(style: .normal, title: nil) { [weak self] (_, _, completionHandler) in
            guard let item = self?.viewModel.items.value[indexPath.row] else {
                completionHandler(false)
                return
            }
            self?.viewModel.setDone(todoId: item.id, !item.done)
            completionHandler(true)
        }
        action.image = R.Images.completedSwipeAction
        action.backgroundColor = R.Colors.completedSwipeAction
        return UISwipeActionsConfiguration(actions: [action])
    }

    func tableView(_ tableView: UITableView, trailingSwipeActionsConfigurationForRowAt indexPath: IndexPath) -> UISwipeActionsConfiguration? {
        if indexPath.row == viewModel.items.value.count {
            return nil
        }

        let detailsAction = UIContextualAction(style: .normal, title: nil) { [weak self] (_, _, completionHandler) in
            self?.presentDetailsView(tableView: tableView, indexPath: indexPath)
            completionHandler(true)
        }
        detailsAction.image = R.Images.detailsSwipeAction
        detailsAction.backgroundColor = R.Colors.detailsSwipeAction

        let removeAction = UIContextualAction(style: .normal, title: nil) { [weak self] (_, _, completionHandler) in
            guard let id = self?.viewModel.items.value[indexPath.row].id else {
                return
            }
            self?.viewModel.remove(todoId: id)
            completionHandler(true)
        }
        removeAction.image = R.Images.removeSwipeAction
        removeAction.backgroundColor = R.Colors.removeSwipeAction

        return UISwipeActionsConfiguration(actions: [removeAction, detailsAction])
    }
}

extension TodoListViewController: UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return viewModel.items.value.count + 1
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        if indexPath.row == viewModel.items.value.count {
            let config = AddTodoItemCellConfiguration()
            config.didTapReturnKey = { [weak self] in
                self?.viewModel.add($0)
            }

            let cell = UITableViewCell()
            cell.contentConfiguration = config
            cell.selectionStyle = .none
            return cell
        }

        let cell = tableView.dequeueReusableCell(withIdentifier: Self.cellReuseIdentifier, for: indexPath)

        let config = TodoItemCellConfiguration(item: viewModel.items.value[indexPath.row])
        config.didChangeChecked = { [weak self] in
            guard let id = self?.viewModel.items.value[indexPath.row].id else {
                return
            }
            self?.viewModel.setDone(todoId: id, $0)
        }

        cell.contentConfiguration = config

        return cell
    }
}
