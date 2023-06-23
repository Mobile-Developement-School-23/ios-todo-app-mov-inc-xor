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
        label.textColor = R.Colors.text
        return label
    }()
    
    private lazy var deadlineDateLabel: UILabel = {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.font = UIFont.systemFont(ofSize: 13, weight: .bold)
        label.textColor = R.Colors.accentText
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
    
    private lazy var switcher: UISwitch = {
        let switcher = UISwitch()
        switcher.translatesAutoresizingMaskIntoConstraints = false
        switcher.onTintColor = R.Colors.switchOnBackground
        switcher.layer.cornerRadius = switcher.frame.height / 2.0
        switcher.clipsToBounds = true
        switcher.isOn = viewModel.date.value != nil
        
        setSwitcherBackground(switcher)
        
        switcher.addAction(UIAction { [weak self] in
            guard let sender = ($0.sender as? UISwitch) else {
                return
            }
            self?.viewModel.didChangeSwitchValue?(sender.isOn)
            self?.setSwitcherBackground(switcher)
        }, for: .valueChanged)

        return switcher
    }()
    
    // Хак для корректного изменения цвета фона у UISwitch
    func setSwitcherBackground(_ switcher: UISwitch) {
        switcher.subviews.first?.subviews.first?.backgroundColor = R.Colors.switchOffBackground
    }
    
    // При изменении темы нужно повторно изменить цвет фона
    override func traitCollectionDidChange(_ previousTraitCollection: UITraitCollection?) {
        super.traitCollectionDidChange(previousTraitCollection)
        
        // Также хак для изменения цвета, без DispatchQueue не сработает
        DispatchQueue.main.async { [weak self] in
            guard let self else { return }
            self.setSwitcherBackground(self.switcher)
        }
    }
    
    init(viewModel: DeadlineOptionViewModel) {
        self.viewModel = viewModel
        super.init(frame: .null)
        
        bind()
        setup()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private func bind() {
        viewModel.date.bind { [weak self] date in
            if date != nil {
                self?.deadlineDateLabel.text = self?.format(date)
            }

            self?.switcher.isOn = date != nil

            UIView.animate(withDuration: 0.3, delay: 0, options: [.transitionCurlDown]) { [weak self] in
                self?.deadlineDateLabel.isHidden = date == nil
                self?.deadlineDateLabel.layer.opacity = date == nil ? 0 : 1
            } completion: { [weak self] _ in
                self?.deadlineDateLabel.text = self?.format(date)
            }
        }
    }
    
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
        ])
    }
}
