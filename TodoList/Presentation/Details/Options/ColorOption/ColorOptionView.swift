import UIKit

class ColorOptionView: UIView {
    var viewModel: ColorOptionViewModel
    
    private static let circleDiameter: CGFloat = 13
    
    private lazy var textLabel: UILabel = {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.text = "Цвет"
        label.textColor = R.Colors.text
        return label
    }()
    
    private lazy var colorStackView: UIStackView = {
        let stack = UIStackView()
        stack.translatesAutoresizingMaskIntoConstraints = false
        stack.alignment = .center
        stack.axis = .horizontal
        stack.distribution = .equalSpacing
        stack.spacing = 5
        stack.isHidden = viewModel.color.value == nil
        stack.layer.opacity = viewModel.color.value == nil ? 0 : 1
        return stack
    }()
    
    private lazy var textStackView: UIStackView = {
        let stack = UIStackView()
        stack.translatesAutoresizingMaskIntoConstraints = false
        stack.axis = .vertical
        stack.alignment = .leading
        return stack
    }()

    private lazy var hexColorLabel: UILabel = {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.text = viewModel.color.value?.hex() ?? R.Colors.text?.hex()
        label.font = UIFont.boldSystemFont(ofSize: 13)
        label.textColor = R.Colors.accentText
        return label
    }()
    
    private lazy var colorCircle: UIView = {
        let view = UIView()
        view.translatesAutoresizingMaskIntoConstraints = false
        view.backgroundColor = viewModel.color.value ?? R.Colors.text
        view.layer.cornerRadius = Self.circleDiameter / 2
        return view
    }()
    
    private lazy var switcher: TodoSwitch = {
        let action = UIAction { [weak self] in
            guard let sender = $0.sender as? UISwitch else { return }
            if sender.isOn {
                self?.viewModel.color.value = R.Colors.accentText
            }
            
            UIView.animate(withDuration: 0.2, delay: 0, options: [.transitionCurlDown]) { [weak self] in
                self?.colorStackView.isHidden = !sender.isOn
                self?.colorStackView.layer.opacity = sender.isOn ? 1 : 0
            } completion: { _ in
                self?.viewModel.color.value = sender.isOn ? R.Colors.accentText : nil
            }
            self?.viewModel.didChangeSwitchValue?(sender.isOn)
        }
        
        let switcher = TodoSwitch()
        switcher.translatesAutoresizingMaskIntoConstraints = false
        switcher.addAction(action, for: .valueChanged)
        switcher.isOn = viewModel.color.value != nil
        return switcher
    }()
    
    init(viewModel: ColorOptionViewModel) {
        self.viewModel = viewModel
        super.init(frame: .null)
        
        setup()
        bind()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}

extension ColorOptionView {
    private func bind() {
        viewModel.color.bind { [weak self] color in
            self?.colorCircle.backgroundColor = color ?? R.Colors.text
            self?.hexColorLabel.text = color?.hex() ?? R.Colors.text?.hex()
        }
    }
}

extension ColorOptionView {
    private func setup() {
        colorStackView.addArrangedSubview(colorCircle)
        colorStackView.addArrangedSubview(hexColorLabel)
        
        textStackView.addArrangedSubview(textLabel)
        textStackView.addArrangedSubview(colorStackView)
        
        addSubview(textStackView)
        addSubview(switcher)
        
        NSLayoutConstraint.activate([
            textStackView.leadingAnchor.constraint(equalTo: leadingAnchor),
            textStackView.centerYAnchor.constraint(equalTo: centerYAnchor),
            
            switcher.trailingAnchor.constraint(equalTo: trailingAnchor),
            switcher.centerYAnchor.constraint(equalTo: centerYAnchor),
            
            colorCircle.widthAnchor.constraint(equalToConstant: Self.circleDiameter),
            colorCircle.heightAnchor.constraint(equalToConstant: Self.circleDiameter),
            
            colorStackView.topAnchor.constraint(equalTo: textLabel.bottomAnchor),
        ])
    }
}
