import UIKit

class DetailsViewController: UIViewController {
    var viewModel: DetailsViewModel
    
    init(viewModel: DetailsViewModel) {
        self.viewModel = viewModel
        super.init(nibName: nil, bundle: nil)
    }
    
    deinit {
        NotificationCenter.default.removeObserver(self)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private lazy var leftBarButtonItem: UIBarButtonItem = {
        let action = UIAction { [weak self] _ in
            self?.dismiss(animated: true)
        }
        let button = UIBarButtonItem(title: "Отменить", primaryAction: action)
        return button
    }()
    
    private lazy var rightBarButtonItem: UIBarButtonItem = {
        let action = UIAction { [weak self] _ in
            guard let self else { return }
            do {
                try self.viewModel.save()
            } catch {
                self.present(Alerts.makeErrorAlert(message: "Не удалось сохранить задачу"), animated: true)
                return
            }
            self.dismiss(animated: true)
        }
        let button = UIBarButtonItem(title: "Сохранить", primaryAction: action)
        button.style = .done
        button.isEnabled = !textView.text.isEmpty
        return button
    }()
    
    private lazy var contentView: UIStackView = {
        let stack = UIStackView()
        stack.translatesAutoresizingMaskIntoConstraints = false
        stack.axis = .vertical
        stack.distribution = .equalSpacing
        stack.spacing = 16
        return stack
    }()
    
    private lazy var scrollView: UIScrollView = {
        let scrollView = UIScrollView()
        scrollView.translatesAutoresizingMaskIntoConstraints = false
        return scrollView
    }()
    
    private lazy var textView: TodoTextView = {
        let textField = TodoTextView()
        textField.translatesAutoresizingMaskIntoConstraints = false
        textField.textColor = UIColor.colorWithHexString(hexString: viewModel.hexColor.value ?? R.Colors.text?.hex() ?? "#000000")
        return textField
    }()
    
    private lazy var optionsView: OptionsView = {
        let vm = OptionsViewModel(
            importance: viewModel.importance.value,
            color: UIColor.colorWithHexString(hexString: viewModel.hexColor.value ?? R.Colors.text?.hex() ?? "#000000"),
            deadline: viewModel.deadline.value
        )
        
        let optionsView = OptionsView(viewModel: vm)
        optionsView.translatesAutoresizingMaskIntoConstraints = false
        optionsView.backgroundColor = R.Colors.featureBackground
        optionsView.layer.cornerRadius = 16
        return optionsView
    }()
    
    private lazy var removeButton: UIButton = {
        let action = UIAction { [weak self] _ in
            let alert = Alerts.makeConfirmAlert(
                title: "Удаление",
                message: "Вы действительно хотите удалить задачу?") { [weak self] _ in
                    do {
                        try self?.viewModel.remove()
                    } catch {
                        self?.present(Alerts.makeErrorAlert(message: "Не удалось удалить задачу"), animated: true)
                        return
                    }
                    self?.dismiss(animated: true)
                }
            self?.present(alert, animated: true)
        }

        let button = UIButton(type: .system)
        button.translatesAutoresizingMaskIntoConstraints = false
        button.setTitle("Удалить", for: .normal)
        button.layer.cornerRadius = 16
        button.backgroundColor = R.Colors.featureBackground
        button.setTitleColor(R.Colors.attentionText, for: .normal)
        button.setTitleColor(R.Colors.disabledText, for: .disabled)
        button.titleLabel?.font = UIFont.systemFont(ofSize: 17)
        button.addAction(action, for: .touchUpInside)
        button.isEnabled = viewModel.editingMode.value
        return button
    }()

    override func viewDidLoad() {
        bind()
        addKeyboardObservers()
        addGestureRecognizers()
        setupView()
        setupConstraints() 
    }
    
    private func bind() {
        viewModel.editingMode.bind { [weak self] in
            self?.removeButton.isEnabled = $0
        }
        
        viewModel.text.bind { [weak self] in
            self?.textView.setText($0)
        }
        
        viewModel.importance.bind { [weak self] in
            self?.optionsView.importanceOptionView.viewModel.importance.value = $0
        }
        
        viewModel.deadline.bind { [weak self] in
            self?.optionsView.deadlineOptionView.viewModel.date.value = $0
            guard let date = $0 else { return }
            let dc = Calendar.current.dateComponents([.year, .month, .day], from: date)
            let calendarSelection = (self?.optionsView.calendarView.selectionBehavior as? UICalendarSelectionSingleDate)
            calendarSelection?.setSelected(dc, animated: true)
        }
        
        textView.didChangeText = { [weak self] in
            self?.viewModel.text.value = $0
            self?.rightBarButtonItem.isEnabled = !$0.isEmpty
        }
        
        textView.onTextViewDidBeginEditing = { [weak self] in
            self?.optionsView.setCalendarVisibility(false)
        }
        
        optionsView.importanceOptionView.viewModel.didChangeImportance = { [weak self] in
            self?.viewModel.importance.value = $0
        }
        
        optionsView.calendarView.didChangeDate = { [weak self] in
            self?.optionsView.setCalendarVisibility(false)
            self?.viewModel.deadline.value = $0
        }
        
        optionsView.deadlineOptionView.viewModel.didChangeSwitchValue = { [weak self] hasDeadline in
            if !hasDeadline {
                self?.optionsView.setCalendarVisibility(false)
            }
            
            let nextDate = Calendar.current.date(byAdding: DateComponents(day: 1), to: Date()) ?? Date()
            
            let dc = Calendar.current.dateComponents([.year, .month, .day], from: nextDate)
            let calendarSelection = (self?.optionsView.calendarView.selectionBehavior as? UICalendarSelectionSingleDate)
            calendarSelection?.setSelected(dc, animated: true)
            
            self?.viewModel.deadline.value = hasDeadline ? nextDate : nil
        }
        
        optionsView.viewModel.didTapDate = { [weak self] in
            guard let self else { return }
            if self.optionsView.deadlineOptionView.viewModel.date.value != nil {
                self.optionsView.setCalendarVisibility(self.optionsView.calendarView.isHidden)
            }
            self.view.endEditing(true)
        }
        
        optionsView.colorOptionView.viewModel.didChangeColor = { [weak self] in
            self?.textView.textColor = $0
            self?.viewModel.hexColor.value = $0.hex()
        }
    }
    
    @objc private func handleTap(_ gesture: UITapGestureRecognizer) {
        // Скрываем клавиатуру
        textView.endEditing(true)
        
        let touchPoint = gesture.location(in: self.view)
        let convertedPoint = self.view.convert(touchPoint, to: optionsView.calendarView)
        
        // Если касание было вне календаря, то скрываем его
        if !optionsView.calendarView.bounds.contains(convertedPoint) {
            optionsView.setCalendarVisibility(false)
        }
    }
    
    @objc private func keyboardWillShow(_ notification: Notification) {
        guard
            let userInfo = notification.userInfo,
            let keyboardFrame = userInfo[UIResponder.keyboardFrameEndUserInfoKey] as? CGRect
        else {
            return
        }
        scrollView.contentInset.bottom += keyboardFrame.height - 22
    }
    
    @objc private func keyboardWillHide(_ notification: Notification) {
        let contentInset = UIEdgeInsets.zero
        scrollView.contentInset = contentInset
    }
    
    private func addKeyboardObservers() {
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillShow), name: UIResponder.keyboardWillShowNotification, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillHide), name: UIResponder.keyboardWillHideNotification, object: nil)
    }
    
    private func addGestureRecognizers() {
        let tap = UITapGestureRecognizer(target: self, action: #selector(handleTap))
        tap.cancelsTouchesInView = false
        view.addGestureRecognizer(tap)
    }
    
    private func setupView() {
        view.backgroundColor = R.Colors.appBackground
        
        title = "Дело"
        navigationItem.leftBarButtonItem = leftBarButtonItem
        navigationItem.rightBarButtonItem = rightBarButtonItem
        
        contentView.addArrangedSubview(textView)
        contentView.addArrangedSubview(optionsView)
        contentView.addArrangedSubview(removeButton)
        
        scrollView.addSubview(contentView)
        
        view.addSubview(scrollView)
    }
    
    private func setupConstraints() {
        NSLayoutConstraint.activate([
            scrollView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor),
            scrollView.leadingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.leadingAnchor),
            scrollView.trailingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.trailingAnchor),
            scrollView.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor),
        
            contentView.leadingAnchor.constraint(equalTo: scrollView.leadingAnchor, constant: 16),
            contentView.trailingAnchor.constraint(equalTo: scrollView.trailingAnchor, constant: -16),
            contentView.topAnchor.constraint(equalTo: scrollView.topAnchor, constant: 16),
            contentView.bottomAnchor.constraint(equalTo: scrollView.bottomAnchor),
            contentView.widthAnchor.constraint(equalTo: scrollView.widthAnchor, constant: -32),
            
            textView.heightAnchor.constraint(greaterThanOrEqualToConstant: 120),
            
            removeButton.heightAnchor.constraint(equalToConstant: 56),
        ])
    }
}
