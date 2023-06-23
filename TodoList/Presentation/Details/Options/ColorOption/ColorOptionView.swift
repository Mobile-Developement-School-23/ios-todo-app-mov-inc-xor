import UIKit

class ColorOptionView: UIView {
    var viewModel: ColorOptionViewModel
    
    private static let circleDiameter: CGFloat = 35
    
    private lazy var colorLabel: UILabel = {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.text = "Цвет"
        label.textColor = R.Colors.text
        return label
    }()
    
    private lazy var hexColorLabel: UILabel = {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.text = viewModel.color.value.hex()
        label.font = UIFont.systemFont(ofSize: 13)
        label.textColor = R.Colors.text
        return label
    }()
    
    private lazy var colorCircle: UIView = {
        let view = UIView()
        view.translatesAutoresizingMaskIntoConstraints = false
        view.backgroundColor = viewModel.color.value
        view.layer.cornerRadius = Self.circleDiameter / 2
        return view
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
    
    private func bind() {
        viewModel.color.bind { [weak self] in
            self?.colorCircle.backgroundColor = $0
            self?.hexColorLabel.text = $0.hex()
            self?.viewModel.didChangeColor?($0)
        }
    }
    
    private func setup() {
        addSubview(colorLabel)
        addSubview(hexColorLabel)
        addSubview(colorCircle)
        
        NSLayoutConstraint.activate([
            colorLabel.leadingAnchor.constraint(equalTo: leadingAnchor),
            colorLabel.centerYAnchor.constraint(equalTo: centerYAnchor),
            
            hexColorLabel.trailingAnchor.constraint(equalTo: colorCircle.leadingAnchor, constant: -16),
            hexColorLabel.centerYAnchor.constraint(equalTo: centerYAnchor),
            
            colorCircle.trailingAnchor.constraint(equalTo: trailingAnchor),
            colorCircle.centerYAnchor.constraint(equalTo: centerYAnchor),
            
            colorCircle.widthAnchor.constraint(equalToConstant: Self.circleDiameter),
            colorCircle.heightAnchor.constraint(equalToConstant: Self.circleDiameter),
        ])
    }
}
