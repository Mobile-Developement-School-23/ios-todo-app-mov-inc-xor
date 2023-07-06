import UIKit

class DeadlineOptionView: UIView {
    var viewModel: DeadlineOptionViewModel

    func format(_ date: Date?) -> String {
        let dateFormatter = DateFormatter()
        dateFormatter.locale = Locale(identifier: "ru_RU")
        dateFormatter.dateFormat = "dd MMMM YYYY"
        return date.flatMap({ dateFormatter.string(from: $0) }) ?? ""
    }

    private lazy var deadlineLabel: UILabel = {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.text = "Сделать до"
        label.textColor = Res.Colors.text
        return label
    }()

    private lazy var deadlineDateLabel: UILabel = {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.font = UIFont.boldSystemFont(ofSize: 13)
        label.textColor = Res.Colors.accentText
        label.layer.opacity = viewModel.date.value == nil ? 0 : 1
        label.isHidden = viewModel.date.value == nil
        return label
    }()

    private lazy var textContentView: UIStackView = {
        let stack = UIStackView()
        stack.translatesAutoresizingMaskIntoConstraints = false
        stack.axis = .vertical
        stack.alignment = .leading
        return stack
    }()

    private lazy var switcher: TodoSwitch = {
        let action = UIAction { [weak self] in
            guard let sender = ($0.sender as? UISwitch) else { return }
            self?.viewModel.didChangeSwitchValue?(sender.isOn)
        }

        let switcher = TodoSwitch()
        switcher.translatesAutoresizingMaskIntoConstraints = false
        switcher.isOn = viewModel.date.value != nil
        switcher.addAction(action, for: .valueChanged)
        return switcher
    }()

    init(viewModel: DeadlineOptionViewModel) {
        self.viewModel = viewModel
        super.init(frame: .null)

        bind()
        setup()
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}

extension DeadlineOptionView {
    private func bind() {
        viewModel.date.bind { [weak self] date in
            if date != nil {
                self?.deadlineDateLabel.text = self?.format(date)
            }

            self?.switcher.isOn = date != nil

            UIView.animate(withDuration: 0.2) { [weak self] in
                self?.deadlineDateLabel.isHidden = date == nil
                self?.deadlineDateLabel.layer.opacity = date == nil ? 0 : 1
            } completion: { [weak self] _ in
                self?.deadlineDateLabel.text = self?.format(date)
            }
        }
    }
}

extension DeadlineOptionView {
    private func setup() {
        textContentView.addArrangedSubview(deadlineLabel)
        textContentView.addArrangedSubview(deadlineDateLabel)

        addSubview(textContentView)
        addSubview(switcher)

        NSLayoutConstraint.activate([
            textContentView.leadingAnchor.constraint(equalTo: leadingAnchor),
            textContentView.centerYAnchor.constraint(equalTo: centerYAnchor),

            switcher.trailingAnchor.constraint(equalTo: trailingAnchor),
            switcher.centerYAnchor.constraint(equalTo: centerYAnchor),

            deadlineDateLabel.topAnchor.constraint(equalTo: deadlineLabel.bottomAnchor),
            deadlineDateLabel.heightAnchor.constraint(equalToConstant: 18)
        ])
    }
}
