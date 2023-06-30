import UIKit

class TodoCheckboxView: UIControl {
    var viewModel: TodoCheckboxViewModel
    
    private var image: UIImage? {
        if viewModel.checked.value {
            return R.Images.checkedCheckbox
        }
        
        if viewModel.type.value == .basic {
            return R.Images.basicCheckbox
        }
        
        return R.Images.importantCheckbox
    }
    
    private lazy var imageView: UIImageView = {
        let imageView = UIImageView()
        imageView.translatesAutoresizingMaskIntoConstraints = false
        imageView.image = image
        return imageView
    }()
    
    init(viewModel: TodoCheckboxViewModel) {
        self.viewModel = viewModel
        super.init(frame: .zero)
        
        bind()
        setup()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}

extension TodoCheckboxView {
    private func bind() {
        viewModel.checked.bind { [weak self] _ in
            self?.imageView.image = self?.image
        }
        
        viewModel.type.bind { [weak self] _ in
            self?.imageView.image = self?.image
        }
    }
}

extension TodoCheckboxView {
    private func setup() {
        let action = UIAction { [weak self] _ in
            guard let self else { return }
            let value = !self.viewModel.checked.value
            self.viewModel.checked.value = value
            self.viewModel.didChangeValue?(value)
        }
        addAction(action, for: .touchUpInside)

        addSubview(imageView)
        
        NSLayoutConstraint.activate([
            imageView.leadingAnchor.constraint(equalTo: leadingAnchor),
            imageView.trailingAnchor.constraint(equalTo: trailingAnchor),
            imageView.topAnchor.constraint(equalTo: topAnchor),
            imageView.bottomAnchor.constraint(equalTo: bottomAnchor),
            
            imageView.widthAnchor.constraint(equalToConstant: 24),
            imageView.heightAnchor.constraint(equalToConstant: 24),
            imageView.centerXAnchor.constraint(equalTo: centerXAnchor),
            imageView.centerYAnchor.constraint(equalTo: centerYAnchor),
        ])
    }
}
