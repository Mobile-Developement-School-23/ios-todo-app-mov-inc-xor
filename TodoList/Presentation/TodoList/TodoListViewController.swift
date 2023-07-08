import UIKit

class TodoListViewController: UITableViewController {
    var viewModel: TodoListViewModel

    private static let cellReuseIdentifier = "todo_cell"

    private lazy var doneCountLabel: UILabel = {
        let label = UILabel()
        label.textColor = Res.Colors.disabledText
        label.font = .systemFont(ofSize: 15)
        return label
    }()

    private lazy var toggleCompletedButton: UIButton = {
        let action = UIAction { [weak self] _ in
            self?.viewModel.toggleCompletedItems()
            self?.tableView.reloadData()
        }

        let button = UIButton(type: .system)
        button.setTitle("Показать", for: .normal)
        button.titleLabel?.font = .boldSystemFont(ofSize: 15)
        button.addAction(action, for: .touchUpInside)
        return button
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

    private lazy var spinnerView: UIBarButtonItem = {
        let activityIndicator = UIActivityIndicatorView()
        activityIndicator.startAnimating()

        let spinnerView = UIBarButtonItem(customView: activityIndicator)
        spinnerView.isHidden = !viewModel.loading.value
        return spinnerView
    }()

    private lazy var refreshSpinner: UIRefreshControl = {
        let action = UIAction { [weak self] _ in
            self?.viewModel.fetchTodoItems()
            self?.tableView.reloadData()
        }

        let refreshControl = UIRefreshControl()
        refreshControl.addAction(action, for: .valueChanged)
        return refreshControl
    }()

    init(viewModel: TodoListViewModel) {
        self.viewModel = viewModel
        super.init(nibName: nil, bundle: nil)
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    deinit {
        NotificationCenter.default.removeObserver(self)
    }

    override func viewDidLoad() {
        viewModel.fetchTodoItems()

        bind()
        setup()
    }

    private func presentDetailsView(tableView: UITableView? = nil, indexPath: IndexPath? = nil) {
        let detailsViewControllerViewModel = DetailsViewModel(
            retryManager: viewModel.retryManager,
            networkService: viewModel.networkService,
            item: indexPath.flatMap { viewModel.tableItems.value[$0.row] }
        )
        detailsViewControllerViewModel.changesCompletion = { [weak self] in
            self?.viewModel.fetchTodoItems()
            self?.tableView.reloadData()
        }

        let detailsViewController = DetailsViewController(viewModel: detailsViewControllerViewModel)
        present(UINavigationController(rootViewController: detailsViewController), animated: true)

        if let tableView, let indexPath {
            tableView.deselectRow(at: indexPath, animated: true)
        }
    }
}

extension TodoListViewController {
    private func bind() {
        viewModel.tableItems.bind { [weak self] _ in
            guard let self else { return }
            self.doneCountLabel.text = "Выполнено — \(Array(self.viewModel.items.filter { $0.value.done }).count)"
        }

        viewModel.showCompleted.bind { [weak self] showCompleted in
            guard let self else { return }
            self.toggleCompletedButton.setTitle(showCompleted ? "Скрыть" : "Показать", for: .normal)
            self.toggleCompletedButton.contentHorizontalAlignment = .right
        }

        viewModel.loading.bind { [weak self] loading in
            guard let self else { return }
            self.spinnerView.isHidden = !loading
            if !loading {
                self.tableView.reloadData()
                self.refreshSpinner.endRefreshing()
            }
        }
    }
}

extension TodoListViewController {
    private func setup() {
        title = "Мои дела"

        let textAttributes: [NSAttributedString.Key: Any] = [
            .foregroundColor: Res.Colors.text as Any
        ]

        navigationController?.navigationBar.layoutMargins.left = 32
        navigationController?.view.backgroundColor = Res.Colors.appBackground
        navigationController?.navigationBar.isTranslucent = false
        navigationController?.navigationBar.barTintColor = Res.Colors.navBarBackground
        navigationController?.navigationBar.titleTextAttributes = textAttributes
        navigationController?.navigationBar.largeTitleTextAttributes = textAttributes
        navigationController?.navigationBar.prefersLargeTitles = true

        navigationItem.setRightBarButton(spinnerView, animated: true)

        tableView = UITableView(frame: .zero, style: .insetGrouped)
        tableView.delegate = self
        tableView.dataSource = self
        tableView.backgroundColor = Res.Colors.appBackground
        tableView.separatorInset.left = 52
        tableView.register(UITableViewCell.self, forCellReuseIdentifier: Self.cellReuseIdentifier)
        tableView.sectionHeaderHeight = 40
        tableView.keyboardDismissMode = .interactive
        tableView.refreshControl = refreshSpinner

        extendedLayoutIncludesOpaqueBars = true

        view.addSubview(addButton)

        NSLayoutConstraint.activate([
            addButton.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            addButton.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor, constant: -20)
        ])
    }
}

extension TodoListViewController {
    override func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        let headerWidth = view.frame.size.width
        let viewWidth = (headerWidth - 16 * 3) / 2

        let header = UIView(frame: CGRect(x: 0, y: 0, width: headerWidth, height: 40))
        header.autoresizingMask = [.flexibleWidth]

        doneCountLabel.frame = CGRect(x: 16, y: 12, width: viewWidth, height: 20)
        doneCountLabel.autoresizingMask = [.flexibleWidth]

        toggleCompletedButton.frame = CGRect(x: headerWidth - viewWidth - 16, y: 12, width: viewWidth, height: 20)
        toggleCompletedButton.autoresizingMask = [.flexibleWidth]

        header.addSubview(doneCountLabel)
        header.addSubview(toggleCompletedButton)

        return header
    }

    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        if indexPath.row == viewModel.tableItems.value.count {
            return
        }
        presentDetailsView(tableView: tableView, indexPath: indexPath)
    }

    override func tableView(
        _ tableView: UITableView,
        leadingSwipeActionsConfigurationForRowAt indexPath: IndexPath
    ) -> UISwipeActionsConfiguration? {
        if indexPath.row == viewModel.tableItems.value.count {
            return nil
        }

        let performAction = UIContextualAction(style: .normal, title: nil) { [weak self] (_, _, completionHandler) in
            guard let self else {
                completionHandler(false)
                return
            }
            let item = self.viewModel.tableItems.value[indexPath.row]
            let newCheckedValue = !item.done
            self.viewModel.setDone(todoId: item.id, newCheckedValue)
            if newCheckedValue && !self.viewModel.showCompleted.value {
                self.tableView.deleteRows(at: [indexPath], with: .right)
            } else {
                self.tableView.reloadRows(at: [indexPath], with: .none)
            }
            completionHandler(true)
        }
        performAction.image = Res.Images.completedSwipeAction
        performAction.backgroundColor = Res.Colors.completedSwipeAction
        return UISwipeActionsConfiguration(actions: [performAction])
    }

    override func tableView(
        _ tableView: UITableView,
        trailingSwipeActionsConfigurationForRowAt indexPath: IndexPath
    ) -> UISwipeActionsConfiguration? {
        if indexPath.row == viewModel.tableItems.value.count {
            return nil
        }

        let detailsAction = UIContextualAction(style: .normal, title: nil) { [weak self] (_, _, completionHandler) in
            self?.presentDetailsView(tableView: tableView, indexPath: indexPath)
            completionHandler(true)
        }
        detailsAction.image = Res.Images.detailsSwipeAction
        detailsAction.backgroundColor = Res.Colors.detailsSwipeAction

        let removeAction = UIContextualAction(style: .normal, title: nil) { [weak self] (_, _, completionHandler) in
            guard let id = self?.viewModel.tableItems.value[indexPath.row].id else {
                return
            }
            self?.viewModel.remove(todoId: id)
            self?.tableView.deleteRows(at: [indexPath], with: .left)
            completionHandler(true)
        }
        removeAction.image = Res.Images.removeSwipeAction
        removeAction.backgroundColor = Res.Colors.removeSwipeAction

        return UISwipeActionsConfiguration(actions: [removeAction, detailsAction])
    }
}

extension TodoListViewController {
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return viewModel.tableItems.value.count + 1
    }

    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        if indexPath.row == viewModel.tableItems.value.count {
            let config = AddTodoItemCellConfiguration()
            config.didTapReturnKey = { [weak self] in
                guard let self else { return }
                self.viewModel.add($0)
                let idx = IndexPath(row: self.viewModel.tableItems.value.count - 1, section: 0)
                self.tableView.insertRows(at: [idx], with: .fade)
            }

            let cell = UITableViewCell()
            cell.contentConfiguration = config
            cell.selectionStyle = .none
            return cell
        }

        let cell = tableView.dequeueReusableCell(withIdentifier: Self.cellReuseIdentifier, for: indexPath)

        let config = TodoItemCellConfiguration(item: viewModel.tableItems.value[indexPath.row])
        config.didChangeChecked = { [weak self, weak tableView, weak config] checked in
            guard
                let self,
                let config,
                let idx = tableView?.indexPath(for: cell)
            else {
                return
            }
            self.viewModel.setDone(todoId: config.item.id, checked)
            if checked && !self.viewModel.showCompleted.value {
                tableView?.deleteRows(at: [idx], with: .right)
            } else {
                tableView?.reloadRows(at: [idx], with: .none)
            }
        }

        cell.contentConfiguration = config

        return cell
    }
}
