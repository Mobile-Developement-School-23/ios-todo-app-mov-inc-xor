import UIKit

class OptionsView: UIView {
    var viewModel: OptionsViewModel

    private static let cellHeight: CGFloat = 56

    private(set) lazy var importanceOptionView: ImportanceOptionView = {
        let importanceViewModel = ImportanceOptionViewModel(importance: viewModel.importance.value)

        let importance = ImportanceOptionView(viewModel: importanceViewModel)
        importance.translatesAutoresizingMaskIntoConstraints = false
        return importance
    }()

    private(set) lazy var colorOptionView: ColorOptionView = {
        let color = ColorOptionView(viewModel: ColorOptionViewModel(color: viewModel.color.value))
        color.translatesAutoresizingMaskIntoConstraints = false
        color.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(didTapColorOption)))
        return color
    }()

    private lazy var colorPickerContainerHeightConstraint: NSLayoutConstraint = {
        let constraint = colorPickerContainer.heightAnchor.constraint(equalToConstant: 0)
        constraint.isActive = true
        return constraint
    }()

    // Необходим для анимированного появления HSLColorPickerView
    private lazy var colorPickerContainer: UIView = {
        let view = UIView()
        view.translatesAutoresizingMaskIntoConstraints = false
        view.clipsToBounds = true
        return view
    }()

    private(set) lazy var colorPickerView: HSLColorPickerView = {
        let colorPicker = HSLColorPickerView(viewModel: HSLColorPickerViewModel(color: .blue))
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
        viewModel.didTapDeadlineOption?()
    }

    @objc func didTapColorOption() {
        viewModel.didTapColorOption?()
    }

    private var separator: UIView {
        let separator = UIView()
        separator.translatesAutoresizingMaskIntoConstraints = false
        separator.backgroundColor = Res.Colors.separator
        separator.heightAnchor.constraint(equalToConstant: 1.0 / UIScreen.main.scale).isActive = true
        return separator
    }

    private var separatorBeforeCalendar: UIView!

    private var separatorBeforeColorPicker: UIView!

    private(set) lazy var calendarView: TodoCalendarView = {
        let calendarView = TodoCalendarView()
        calendarView.translatesAutoresizingMaskIntoConstraints = false
        calendarView.clipsToBounds = true

        // Хак, чтобы убрать первую анимацию появления календаря
        calendarView.isHidden = false
        DispatchQueue.main.async { [weak calendarView] in
            calendarView?.isHidden = true
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
        colorPickerView.isHidden = false
        UIView.animate(withDuration: 0.3) { [weak self] in
            guard let self else { return }
            self.separatorBeforeColorPicker.isHidden = !visibility
            self.colorPickerContainerHeightConstraint.constant = visibility ? self.colorPickerView.frame.height : 0
            self.viewModel.updateSuperviewLayout?()
        } completion: { [weak self] _ in
            self?.colorPickerView.isHidden = !visibility
        }
    }
}

extension OptionsView {
    private func bind() {
        viewModel.color.bind { [weak self] color in
            self?.colorOptionView.viewModel.color.value = color
            if let color {
                self?.colorPickerView.viewModel.setColor(color)
            }
        }

        viewModel.importance.bind { [weak self] in
            self?.importanceOptionView.viewModel.importance.value = $0
        }

        viewModel.deadline.bind { [weak self] in
            self?.deadlineOptionView.viewModel.date.value = $0
        }
    }
}

extension OptionsView {
    private func setup() {
        separatorBeforeCalendar = separator
        separatorBeforeColorPicker = separator

        separatorBeforeCalendar.isHidden = true
        separatorBeforeColorPicker.isHidden = true

        contentView.addArrangedSubview(importanceOptionView)
        contentView.addArrangedSubview(separator)
        contentView.addArrangedSubview(colorOptionView)

        contentView.addArrangedSubview(separatorBeforeColorPicker)

        colorPickerContainer.addSubview(colorPickerView)
        contentView.addArrangedSubview(colorPickerContainer)

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

            colorPickerContainerHeightConstraint,
            colorPickerView.widthAnchor.constraint(equalTo: colorPickerContainer.widthAnchor),

            heightAnchor.constraint(equalTo: contentView.heightAnchor)
        ])
    }
}
