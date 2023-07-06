import UIKit

class TodoItemCellContentView: UIView, UIContentView {
    var configuration: UIContentConfiguration {
        didSet {
            configure()
        }
    }

    private lazy var textLabel: UILabel = {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.numberOfLines = 3
        return label
    }()

    private lazy var contentView: UIStackView = {
        let stack = UIStackView()
        stack.translatesAutoresizingMaskIntoConstraints = false
        stack.axis = .horizontal
        stack.spacing = 12
        stack.alignment = .center
        return stack
    }()

    private lazy var importanceImageView: UIImageView = {
        let imageView = UIImageView()
        imageView.translatesAutoresizingMaskIntoConstraints = false
        return imageView
    }()

    private lazy var textContentView: UIStackView = {
        let stack = UIStackView()
        stack.translatesAutoresizingMaskIntoConstraints = false
        stack.axis = .horizontal
        stack.alignment = .center
        stack.spacing = 4
        return stack
    }()

    private lazy var calendarImageView: UIImageView = {
        let imageView = UIImageView()
        imageView.translatesAutoresizingMaskIntoConstraints = false
        imageView.image = Res.Images.calendar
        return imageView
    }()

    private lazy var deadlineLabel: UILabel = {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.font = .systemFont(ofSize: 15)
        label.textColor = Res.Colors.disabledText
        return label
    }()

    private lazy var deadlineContentView: UIStackView = {
        let stack = UIStackView()
        stack.translatesAutoresizingMaskIntoConstraints = false
        stack.axis = .horizontal
        stack.alignment = .center
        stack.spacing = 3
        return stack
    }()

    private lazy var checkboxView: TodoCheckboxView = {
        let checkbox = TodoCheckboxView(viewModel: TodoCheckboxViewModel())
        checkbox.translatesAutoresizingMaskIntoConstraints = false
        return checkbox
    }()

    private lazy var arrowRightView: UIImageView = {
        let imageView = UIImageView()
        imageView.translatesAutoresizingMaskIntoConstraints = false
        imageView.image = Res.Images.arrowRight
        return imageView
    }()

    private lazy var verticalStackView: UIStackView = {
        let stack = UIStackView()
        stack.translatesAutoresizingMaskIntoConstraints = false
        stack.axis = .vertical
        stack.alignment = .leading
        return stack
    }()

    init(configuration: UIContentConfiguration) {
        self.configuration = configuration
        super.init(frame: .zero)

        configure()
        setup()
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    private func format(_ date: Date?) -> String {
        let dateFormatter = DateFormatter()
        dateFormatter.locale = Locale(identifier: "ru_RU")
        dateFormatter.dateFormat = "dd MMMM"
        return date.flatMap({ dateFormatter.string(from: $0) }) ?? ""
    }

    private func setDone(config: TodoItemCellConfiguration, done: Bool) {
        if done {
            let attributedText = NSMutableAttributedString(string: config.item.text)
            attributedText.addAttribute(
                .strikethroughStyle,
                value: 1,
                range: NSRange(location: 0, length: attributedText.length)
            )

            textLabel.attributedText = attributedText
            textLabel.textColor = Res.Colors.disabledText
        } else {
            textLabel.attributedText = nil
            textLabel.text = config.item.text
            textLabel.textColor = config.item.hexColor.flatMap { UIColor.colorWithHexString(hexString: $0) }
        }
    }

    private func configure() {
        guard let config = configuration as? TodoItemCellConfiguration else {
            return
        }

        setDone(config: config, done: config.item.done)

        importanceImageView.image = config.item.importance == .important ? Res.Images.highImportanceIcon :
                                    config.item.importance == .low ? Res.Images.lowImportanceIcon : nil
        importanceImageView.isHidden = importanceImageView.image == nil

        deadlineLabel.text = format(config.item.deadline)
        deadlineContentView.isHidden = config.item.deadline == nil

        checkboxView.viewModel.checked.value = config.item.done

        checkboxView.viewModel.didChangeValue = nil
        checkboxView.viewModel.type.value = config.item.importance == .important ? .important : .basic
        checkboxView.viewModel.didChangeValue = { [weak config, weak self] in
            guard let config else { return }
            self?.setDone(config: config, done: $0)

            config.checked = $0
            config.didChangeChecked?($0)
        }
    }
}

extension TodoItemCellContentView {
    private func setup() {
        backgroundColor = Res.Colors.featureBackground

        textContentView.addArrangedSubview(importanceImageView)
        textContentView.addArrangedSubview(textLabel)

        deadlineContentView.addArrangedSubview(calendarImageView)
        deadlineContentView.addArrangedSubview(deadlineLabel)

        verticalStackView.addArrangedSubview(textContentView)
        verticalStackView.addArrangedSubview(deadlineContentView)

        contentView.addArrangedSubview(checkboxView)
        contentView.addArrangedSubview(verticalStackView)
        contentView.addArrangedSubview(arrowRightView)

        addSubview(contentView)

        NSLayoutConstraint.activate([
            contentView.leadingAnchor.constraint(equalTo: leadingAnchor, constant: 16),
            contentView.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -16),
            contentView.topAnchor.constraint(equalTo: topAnchor, constant: 16),
            contentView.bottomAnchor.constraint(equalTo: bottomAnchor, constant: -16),

            importanceImageView.widthAnchor.constraint(equalToConstant: 12),
            importanceImageView.heightAnchor.constraint(equalToConstant: 16)
        ])
    }
}
