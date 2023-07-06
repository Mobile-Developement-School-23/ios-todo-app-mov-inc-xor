import UIKit

class AddTodoItemCellContentView: UIView & UIContentView {
    var configuration: UIContentConfiguration

    private lazy var textField: UITextField = {
        let textField = UITextField()
        textField.translatesAutoresizingMaskIntoConstraints = false
        textField.placeholder = "Новое"
        textField.returnKeyType = .done
        textField.delegate = self
        return textField
    }()

    init(configuration: UIContentConfiguration) {
        self.configuration = configuration
        super.init(frame: .zero)

        setup()
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}

extension AddTodoItemCellContentView {
    private func setup() {
        backgroundColor = Res.Colors.featureBackground

        addSubview(textField)

        NSLayoutConstraint.activate([
            textField.leadingAnchor.constraint(equalTo: leadingAnchor, constant: 52),
            textField.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -16),
            textField.topAnchor.constraint(equalTo: topAnchor, constant: 17),
            textField.bottomAnchor.constraint(equalTo: bottomAnchor, constant: -17)
        ])
    }
}

extension AddTodoItemCellContentView: UITextFieldDelegate {
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        let config = configuration as? AddTodoItemCellConfiguration
        let text = textField.text ?? ""

        if text.replacing(/\s+/, with: "") != "" {
            let withTrimmingPrefix = String(text.trimmingPrefix(/\s+/))
            config?.didTapReturnKey?(withTrimmingPrefix)
        }

        textField.text = ""
        endEditing(true)

        return true
    }
}
