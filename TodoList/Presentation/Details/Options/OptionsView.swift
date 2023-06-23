import UIKit

class OptionsView: UIView {
    var viewModel: OptionsViewModel
    
    private static let cellHeight: CGFloat = 56

    private(set) lazy var importanceOptionView: ImportanceOptionView = {
        let importance = ImportanceOptionView(viewModel: ImportanceOptionViewModel(importance: viewModel.importance.value))
        importance.translatesAutoresizingMaskIntoConstraints = false
        return importance
    }()
    
    private(set) lazy var colorOptionView: ColorOptionView = {
        let color = ColorOptionView(viewModel: ColorOptionViewModel(color: viewModel.color.value))
        color.translatesAutoresizingMaskIntoConstraints = false
        color.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(didTapColorOption)))
        return color
    }()
    
    private(set) lazy var colorPickerView: HSLColorPickerView = {
        let colorPicker = HSLColorPickerView(viewModel: HSLColorPickerViewModel(color: colorOptionView.viewModel.color.value))
        colorPicker.translatesAutoresizingMaskIntoConstraints = false
        colorPicker.isHidden = true
        return colorPicker
    }()
    
    private(set) lazy var deadlineOptionView: DeadlineOptionView = {
        let deadline = DeadlineOptionView(viewModel: DeadlineOptionViewModel(date: viewModel.deadline.value))
        deadline.translatesAutoresizingMaskIntoConstraints = false
        deadline.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(didTapDeadline)))
        return deadline
    }()
    
    @objc func didTapDeadline() {
        viewModel.didTapDate?()
    }
    
    @objc func didTapColorOption() {
        setColorPickerVisibility(colorPickerView.isHidden)
    }
    
    private var separator: UIView {
        let separator = UIView()
        separator.translatesAutoresizingMaskIntoConstraints = false
        separator.backgroundColor = R.Colors.separator
        separator.heightAnchor.constraint(equalToConstant: 1.0).isActive = true
        return separator
    }
    
    private var separatorBeforeCalendar: UIView!
    
    private var separatorBeforeColorPicker: UIView!
    
    private(set) lazy var calendarView: TodoCalendarView = {
        let calendarView = TodoCalendarView()
        calendarView.translatesAutoresizingMaskIntoConstraints = false
        
        // Хак, чтобы убрать первую анимацию появления календаря
        calendarView.isHidden = false
        DispatchQueue.main.async {
            calendarView.isHidden = true
        }
        
        return calendarView
    }()
    
    private lazy var contentView: UIStackView = {
        let stack = UIStackView()
        stack.translatesAutoresizingMaskIntoConstraints = false
        stack.axis = .vertical
        return stack
    }()
    
    init(viewModel: OptionsViewModel) {
        self.viewModel = viewModel
        super.init(frame: .null)
        
        setup()
        bind()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    public func setCalendarVisibility(_ visibility: Bool) {
        // Не надо скрывать, если он уже скрыт и не надо показывать, если уже показан
        let calendarVisibility = !calendarView.isHidden
        if visibility == calendarVisibility {
            return
        }
        UIView.animate(withDuration: 0.3) { [weak self] in
            self?.calendarView.isHidden = !visibility
            self?.separatorBeforeCalendar.isHidden = !visibility
        }
    }
    
    public func setColorPickerVisibility(_ visibility: Bool) {
        let colorPickerVisibility = !colorPickerView.isHidden
        if visibility == colorPickerVisibility {
            return
        }
//        UIView.animate(withDuration: 0.3) { [weak self] in
            colorPickerView.isHidden = !visibility
            separatorBeforeColorPicker.isHidden = !visibility
//        }
    }
    
    private func bind() {
        viewModel.color.bind { [weak self] in
            self?.colorOptionView.viewModel.color.value = $0
            self?.colorPickerView.viewModel.setColor($0)
        }
        
        viewModel.importance.bind { [weak self] in
            self?.importanceOptionView.viewModel.importance.value = $0
        }
        
        viewModel.deadline.bind { [weak self] in
            self?.deadlineOptionView.viewModel.date.value = $0
        }
        
        colorPickerView.viewModel.didChangedColor = { [weak self] in
            self?.colorOptionView.viewModel.color.value = $0
        }
    }
    
    private func setup() {
        separatorBeforeCalendar = separator
        separatorBeforeColorPicker = separator
        
        separatorBeforeCalendar.isHidden = true
        separatorBeforeColorPicker.isHidden = true
        
        contentView.addArrangedSubview(importanceOptionView)
        contentView.addArrangedSubview(separator)
        contentView.addArrangedSubview(colorOptionView)
        
        contentView.addArrangedSubview(separatorBeforeColorPicker)
        contentView.addArrangedSubview(colorPickerView)
        
        contentView.addArrangedSubview(separator)
        contentView.addArrangedSubview(deadlineOptionView)
        
        contentView.addArrangedSubview(separatorBeforeCalendar)
        contentView.addArrangedSubview(calendarView)
        
        addSubview(contentView)
        
        NSLayoutConstraint.activate([
            contentView.leadingAnchor.constraint(equalTo: leadingAnchor, constant: 16),
            contentView.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -16),
            
            importanceOptionView.heightAnchor.constraint(equalToConstant: Self.cellHeight),
            colorOptionView.heightAnchor.constraint(equalToConstant: Self.cellHeight),
            deadlineOptionView.heightAnchor.constraint(equalToConstant: Self.cellHeight),
            
            calendarView.centerXAnchor.constraint(equalTo: centerXAnchor),
            
            heightAnchor.constraint(equalTo: contentView.heightAnchor)
        ])
    }
}
